scriptTitle = "Export Games List"
scriptAuthor = "EmiMods"
scriptVersion = 1.0
scriptDescription = "Exports a list of your games (name, titleID) to a text file."
scriptIcon = "icon.png"
scriptPermissions = { "content", "filesystem" }

ExitTriggered = false

function main()
    local collection = Content.FindContent()
    local arrGamesDialog = {}
    local textFileContents = {}
    local textFileContentString = ""

    -- Grab all titleIDs/Games and save for display purposes and export purposes respectively
    for i=1,#collection do
        arrGamesDialog[i] =  collection[i].Name .. " (" .. decToHex(collection[i].TitleId) .. ")"
        textFileContents[i] = collection[i].Name .. ", " .. decToHex(collection[i].TitleId) -- Different from display to make the file easier to work with if needed by user
    end
    
    -- Sort tables alphabetically, case-insensitive
    table.sort(arrGamesDialog, function (a, b) return string.upper(a) < string.upper(b) end)
    table.sort(textFileContents, function (a, b) return string.upper(a) < string.upper(b) end)

    for i=1,#textFileContents do
        textFileContentString = textFileContentString .. textFileContents[i] .. "\n"
    end

    -- Display list of games to be exported
    local foundDialog = Script.ShowPopupList("Found " .. tostring(#collection)..  " titles. Press A to continue.", "No titles found.", arrGamesDialog)
    if not foundDialog.Canceled then
        local path = promptDriveSelect()

        if string.len(path) > 0 then
            path = path .. "\\GamesList.txt"    -- Saves to root of selected drive
    
            if not FileSystem.FileExists(path) then
                FileSystem.WriteFile(path, textFileContentString)
                if FileSystem.FileExists(path) then
                    Script.ShowMessageBox("Success!", "Games list successfully exported to: \n" .. path, "Exit")
                end
            else
                Script.ShowMessageBox("Error", "A game export already exists at: \n" .. path .. ".\n\nPlease rename, move, or delete this file before running this script.", "Exit")
            end
        else
            showCancel()
        end
    else
        showCancel()
    end
end

function showCancel()
    Script.ShowMessageBox("Canceled", "You have exited the script succesfully. Games have not been exported.", "Exit")
end

function decToHex(decimal)
    return string.format("%x", decimal)
end

function promptDriveSelect()
    local arrDrives = {}

    -- Grab list of drives
    for i, drives in ipairs(FileSystem.GetDrives(false)) do
		arrDrives[i] = drives["MountPoint"]
	end

    --Display drives to user for selection
    local dialog = Script.ShowPopupList(
                                            "Please select where to save the text file..",
                                            "No drives found.",
                                            arrDrives
    )

    if not dialog.Canceled then
        return dialog.Selected.Value
    else
        return ""
    end
end