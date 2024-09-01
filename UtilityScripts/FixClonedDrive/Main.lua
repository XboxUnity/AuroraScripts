scriptTitle = "Aurora Cloned Drive Fixer"
scriptAuthor = "EmiMods"
scriptVersion = 1.0
scriptDescription = "Update Aurora database to fix scan paths, grayed-out game covers, missing custom titles, missing title updates, etc on cloned drives."
scriptIcon = "icon.png"
scriptPermissions = { "filesystem", "sql" }

ExitTriggered = false

-- Main entry point to script
function main()
    local updatedScanpaths = false

    -- First grab the desired deviceID
    local newDeviceID = promptDriveSelect()

    if not ExitTriggered and newDeviceID ~= "" then
        local dbScanpathsRows = {}
        local dialogPaths = ""
        local oldDeviceID = ""
        -- Add all rows from Settings.ScanPaths with deviceId not matching newDeviceID to list
        for i, row in pairs(Sql.ExecuteFetchRows("SELECT id, path, deviceid FROM scanpaths ORDER BY id ASC")) do
            if row["DeviceId"] ~= newDeviceID then
                oldDeviceID = row["DeviceId"]
                dbScanpathsRows[i] = { row["Id"], row["Path"], row["DeviceId"] }
                dialogPaths = dialogPaths .. dbScanpathsRows[i][2] .. " - (" .. string.sub(oldDeviceID, 1, 7) .. "..->" .. string.sub(newDeviceID, 1, 7) .. "..)\n"
            end
        end 

        -- Display confirmation box depending on if array is empty
        local isTableEmpty = (rawequal(next(dbScanpathsRows), nil) or #dbScanpathsRows == 0)
        local confirmation
        if isTableEmpty then
            confirmation = Script.ShowMessageBox("Error", "No scanpaths were found which required update. Scanpaths may already be set to appropriate deviceID.\n\nContinue to fix Title Updates?", "Continue", "Exit")
        else
            confirmation = Script.ShowMessageBox("Scan Paths To Be Updated", dialogPaths, "Continue", "Exit")
        end

        if confirmation.Button == 2 then
            ExitTriggered = true
        else
            if not isTableEmpty and not ExitTriggered then
                for _, row in pairs(dbScanpathsRows) do
                    Sql.Execute("UPDATE scanpaths SET deviceid='" .. newDeviceID .. "' WHERE id=" .. row[1] .. ";")
                    updatedScanpaths = true
                end
            end

            if updatedScanpaths then
                confirmation = Script.ShowMessageBox("Update Complete", "Scanpaths have been updated with the selected deviceID. Continue to fix Title Updates?", "Continue", "Exit")
                if confirmation.Button == 2 then
                    promptGenericScanpathRestart()
                end
            end

            -- Begin Title Update flow
            local dbTitleUpdatesRows = {}
            local dialogTitleUpdates = {}

            -- Add all rows from Content.TitleUpdates with LiveDeviceId not matching newDeviceID to list
            for i, row in pairs(Sql.ExecuteFetchRows("SELECT id, displayname, livedeviceid, version FROM titleupdates ORDER BY displayname ASC")) do
                if row["LiveDeviceId"] ~= newDeviceID then  
                    dbTitleUpdatesRows[i] = { row["Id"], row["DisplayName"], row["FileName"], row["LiveDeviceId"], row["TitleId"], row["Version"] }
                    dialogTitleUpdates[i] =  "(TU_" .. row["Version"] .. ") " .. row["DisplayName"]
                end
            end
            isTableEmpty = (rawequal(next(dbTitleUpdatesRows), nil) or #dialogTitleUpdates == 0)

            if not isTableEmpty then
                confirmation = Script.ShowPopupList("Found TUs requiring update. Press A to continue.", "No title updates found.", dialogTitleUpdates)
                
                -- User canceled out of TU list view, exit or prompt restart if required
                if confirmation.Canceled then
                    if updatedScanpaths then
                        promptGenericScanpathRestart()
                    end
                else
                    confirmation = Script.ShowMessageBox("Update?", "Would you like to update the deviceID for these " .. tostring(#dialogTitleUpdates) .. " title updates?", "Yes", "Exit")

                    if confirmation.Button == 1 then
                        for _, row in pairs(dbTitleUpdatesRows) do
                            if row[1] ~= nil then
                                -- Ensure we aren't violating unique constraint when updating TU LiveDeviceId 
                                Sql.Execute("UPDATE titleupdates SET livedeviceid='" .. newDeviceID .. "' WHERE id=" .. row[1] .. " AND filename NOT IN(SELECT filename FROM titleupdates WHERE livedeviceid='" .. newDeviceID .. "' AND titleid='" .. row[6] .. "')" .. ";")
                            end
                        end

                        confirmation = Script.ShowMessageBox("Update Complete", "Title Updates have been updated with the selected deviceID. Script Complete.\n\nA restart is required for changes to take effect. Restart Aurora now?", "Yes", "Exit")
                        if confirmation.Button == 1 then
                            Aurora.Restart()
                        end
                    else
                        if updatedScanpaths then
                            promptGenericScanpathRestart()
                        end
                    end
                end
            else
                -- No title updates found to update, inform and exit or prompt restart if required
                if updatedScanpaths then
                    confirmation = Script.ShowMessageBox("Error", "No title updates were found which required update. Title Updates may not exist or are already set to the appropriate deviceID.\n\nA restart is required for the scanpath changes to take effect. Would you like to restart Aurora now?", "Yes", "Exit")
                    if confirmation.Button == 1 then
                        Aurora.Restart()
                    end
                else
                    confirmation = Script.ShowMessageBox("Error", "No title updates were found which required update. Title Updates may not exist or are already set to the appropriate deviceID.", "Exit")
                end
            end
        end
    end
end

function promptGenericScanpathRestart()
    local restartDialog = Script.ShowMessageBox("Restart Required", "A restart is required for scanpath changes to take effect. Restart Aurora now?", "Yes", "Exit")

    if restartDialog.Button == 1 then
        Aurora.Restart()
    end
end

function promptDriveSelect()
    -- Grab list of drives and form dialog for menu options
    local arrDrives = {}
    local arrDialog = {}
    for i, drives in ipairs(FileSystem.GetDrives(false)) do
		arrDrives[i] = { drives["MountPoint"], drives["Serial"] }
        -- Arbitrary formatting which I think looks nice and lines up well
        local padding = ""
        if (string.len(arrDrives[i][1])*1.25) <= 25 then
            for i=1, 25 - (string.len(arrDrives[i][1])*1.25) do
                padding = padding .. " "
            end
        end

        arrDialog[i] = arrDrives[i][1] .. padding .. "(Serial: " .. string.sub(arrDrives[i][2], 1, 12) .. "...)"
	end

    -- Show the popup selection dialog
    local dialog = Script.ShowPopupList(
                                            "Please select your new/cloned drive.",
                                            "No drives found.",
                                            arrDialog
    )
    
    -- Build confirmation prompt for selection dialog
    if not dialog.Canceled then
        local selectedKey = dialog.Selected.Key
        local dialogSelectedDrive = string.sub(arrDrives[selectedKey][1], 1, (string.len(arrDrives[selectedKey][1]) - 1))
        local serial = arrDrives[dialog.Selected.Key][2]
        local dialogSelectedSerial = string.sub(serial, 1, 28) .. "..."

        local confirmation = Script.ShowMessageBox("New Device Selected", "You have selected:\n-" .. dialogSelectedDrive .. "\n-Serial: " .. dialogSelectedSerial, "Continue", "Exit")
        if confirmation.Button == 2 then
            ExitTriggered = true
            return ""
        else
            return serial
        end
    else
        ExitTriggered = true
    end
end