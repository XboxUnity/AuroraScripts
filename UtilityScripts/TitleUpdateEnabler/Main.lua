scriptTitle = "Title Update Enabler"
scriptAuthor = "FDH"
scriptVersion = 1.0
scriptDescription = "Lets you manage the Aurora-cached title updates"
scriptIcon = "icon.png"
scriptPermissions = { "sql", "filesystem" }

MainMenu = {
    "Enable Latest Updates",
    "Disable Latest Updates",
    "Mass Apply Latest Updates"
}

MainMenuOption_EnableLatest = 1
MainMenuOption_DisableLatest = 2
MainMenuOption_ApplyLatest = 3

-- Main entry point to script
function main()
    ResetToMainMenu()
end

-- Return to start of the application
function ResetToMainMenu()
    -- Show Main Menu
    local selectedMenuOption = ShowMainMenu()

    if selectedMenuOption == MainMenuOption_EnableLatest then
        EnableAllTitleUpdates()
    elseif selectedMenuOption == MainMenuOption_DisableLatest then
        DisableAllTitleUpdates()
    elseif selectedMenuOption == MainMenuOption_ApplyLatest then
        InstallAllTitleUpdates()
    end
end

-- Display Main Menu and return selected option's index, or -1 if cancelled
function ShowMainMenu()
    local dialogBox = Script.ShowPopupList(scriptTitle, "Select an option", MainMenu)
    if not dialogBox.Canceled then
        return dialogBox.Selected.Key
    end
    
    return -1
end

-- Enable all title updates
function EnableAllTitleUpdates()
    -- Check if there are any title updates
    local countResult = Sql.ExecuteFetchRows("SELECT COUNT(*) as Count FROM TitleUpdates")
    local totalTitleUpdates = countResult[1].Count
    
    if totalTitleUpdates == 0 then
        Script.ShowMessageBox("No Title Updates", "No title updates found in database.", "OK")
        ResetToMainMenu()
        return
    end
    
    -- First, clear any existing active title updates
    Sql.Execute("DELETE FROM ActiveTitleUpdates")
    
    -- Insert only the latest title update per game (highest `Version` per TitleId)
    -- Assumes higher `Version` = newer version for the same title
    Sql.Execute([[
        INSERT INTO ActiveTitleUpdates (TitleUpdateId)
        SELECT Id FROM TitleUpdates t1
        WHERE Version = (
            SELECT MAX(Version) FROM TitleUpdates t2
            WHERE t1.TitleId = t2.TitleId
        )
    ]])
    
    -- Count how many were successfully enabled
    local enabledResult = Sql.ExecuteFetchRows("SELECT COUNT(*) as Count FROM ActiveTitleUpdates")
    local enabledCount = enabledResult[1].Count
    
    if enabledCount >= 1 then 
        local ret = Script.ShowMessageBox("Title Updates Enabled", "Successfully enabled " .. enabledCount .. " (" .. totalTitleUpdates ..  " total) latest title updates.\nIn order for the changes to take effect you need to reload Aurora\nDo you want to reload Aurora now?", "Yes", "No")

		if ret.Button == 1 then
			Aurora.Restart();
		end
    else
        Script.ShowMessageBox(
            "Title Updates Enabled", 
            "Enabled " .. enabledCount .. " of " .. totalTitleUpdates .. " title updates.", 
            "OK"
        )
    end
    
    ResetToMainMenu()
end

-- Disable all title updates
function DisableAllTitleUpdates()
    -- Check current count before deleting
    local countResult = Sql.ExecuteFetchRows("SELECT COUNT(*) as Count FROM ActiveTitleUpdates")
    local disabledCount = countResult[1].Count
    
    -- Clear all entries from ActiveTitleUpdates
    Sql.Execute("DELETE FROM ActiveTitleUpdates")
    
    local ret = Script.ShowMessageBox("Title Updates Disabled", disabledCount .. " title updates have been disabled.\nIn order for the changes to take effect you need to reload Aurora\nDo you want to reload Aurora now?", "Yes", "No")

    if ret.Button == 1 then
        Aurora.Restart();
    else 
        ResetToMainMenu()
    end
end

function InstallAllTitleUpdates()
    local ret = Script.ShowMessageBox("Are you sure?", "This will apply the latest enabled title updates. This will clear the title update cache.\nIf you want to use Aurora to manage title updates, you probably shouldn't be doing this!\nAre you sure you want to do this?", "No", "Yes")
    
    if ret.Button == 2 then
        -- Get all active title updates with their details
        local activeTitleUpdates = Sql.ExecuteFetchRows([[
            SELECT tu.Id, tu.FileName, tu.LiveDeviceId, tu.LivePath, tu.TitleId, tu.BackupPath
            FROM TitleUpdates tu
            INNER JOIN ActiveTitleUpdates atu ON tu.Id = atu.TitleUpdateId
        ]])

        if #activeTitleUpdates == 0 then
            Script.ShowMessageBox("No Active Title Updates", "No active title updates found to install.", "OK")
            ResetToMainMenu()
            return
        end

        -- Get an array that's serial -> mount point
        local matchingDrives = {}
        for i, drives in ipairs(FileSystem.GetDrives(false)) do
            matchingDrives[drives["Serial"]] = drives["MountPoint"]
        end

        local total = #activeTitleUpdates
        local successes = 0
        local failures = 0
        
        -- Loop through every currently active title update
        for i, tu in ipairs(activeTitleUpdates) do
            Script.SetStatus("Applying: " .. tu.FileName)
            Script.SetProgress(i, total)

            local destinationPath = (matchingDrives[tu.LiveDeviceId] .. tu.LivePath) .. tu.FileName
            local srcPath = tu.BackupPath

            -- Move it from the backup path to the destination path.
            local success = FileSystem.MoveFile(srcPath, destinationPath, true)
            
            -- If we moved the file successfully, clean it from the database to avoid wonkiness.
            if success then
                Sql.Execute("DELETE FROM TitleUpdates WHERE Id = " .. tu.Id)
                Sql.Execute("DELETE FROM ActiveTitleUpdates WHERE TitleUpdateId = " .. tu.Id)
                successes = successes + 1
            else
                failures = failures + 1
            end
        end

        ret = Script.ShowMessageBox(
            "Mass Apply Complete",
            ("Successfully applied: " .. successes .. "\n" ..
            "Failed: " .. failures .. "\n" ..
            "Total: " .. total .. "\n" .. 
            "In order for the changes to take effect you need to reload Aurora\nDo you want to reload Aurora now?"), 
            "Yes", "No"
        )

        if ret.Button == 1 then
            Aurora.Restart();
        else 
            ResetToMainMenu()
        end
    else
        ResetToMainMenu()
    end
end