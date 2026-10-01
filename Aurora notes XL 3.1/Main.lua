-- ==========================================
-- AURORA NOTES XL
-- Version 3.1
-- ==========================================

scriptTitle = "Aurora Notes XL"
scriptAuthor = "Rawad sm"
scriptVersion = 3.1
scriptDescription = "Persistent multi-note utility with custom names, search, note information and offline text viewer."
scriptIcon = "icon.png"
scriptPermissions = { "filesystem" }


-- ==========================================
-- NOTE SETTINGS
-- ==========================================

MAX_NOTES = 20


-- ==========================================
-- MAIN MENU
-- ==========================================

MainMenu = {
    "New Note",
    "View Notes",
    "Edit Note",
    "Delete Note",
    "Search & Text Viewer",
    "Note Info"
}

MainMenuOption_New = 1
MainMenuOption_View = 2
MainMenuOption_Edit = 3
MainMenuOption_Delete = 4
MainMenuOption_SearchViewer = 5
MainMenuOption_Info = 6


-- ==========================================
-- EDIT MENU
-- ==========================================

EditMenu = {
    "Edit Name",
    "Edit Content"
}

EditMenuOption_Name = 1
EditMenuOption_Content = 2


-- ==========================================
-- SEARCH & TEXT VIEWER MENU
-- ==========================================

SearchViewerMenu = {
    "Search Notes",
    "Open Text File"
}

SearchViewerOption_Search = 1
SearchViewerOption_Text = 2


-- ==========================================
-- NOTE CONTENT FILE
-- ==========================================

function GetNotePath(noteNumber)

    return Script.GetBasePath() ..
        "note" ..
        tostring(noteNumber) ..
        ".txt"

end


-- ==========================================
-- NOTE NAME FILE
-- ==========================================

function GetNoteNamePath(noteNumber)

    return Script.GetBasePath() ..
        "note" ..
        tostring(noteNumber) ..
        "_name.txt"

end


-- ==========================================
-- CHECK NOTE
-- ==========================================

function NoteExists(noteNumber)

    return FileSystem.FileExists(
        GetNotePath(noteNumber)
    )

end


-- ==========================================
-- SAVE NOTE
-- ==========================================

function SaveNote(noteNumber, text)

    return FileSystem.WriteFile(
        GetNotePath(noteNumber),
        text
    )

end


-- ==========================================
-- LOAD NOTE
-- ==========================================

function LoadNote(noteNumber)

    local path =
        GetNotePath(noteNumber)


    if not FileSystem.FileExists(path) then
        return nil
    end


    return FileSystem.ReadFile(path)

end


-- ==========================================
-- SAVE NOTE NAME
-- ==========================================

function SaveNoteName(noteNumber, name)

    return FileSystem.WriteFile(
        GetNoteNamePath(noteNumber),
        name
    )

end


-- ==========================================
-- LOAD NOTE NAME
-- ==========================================

function LoadNoteName(noteNumber)

    local path =
        GetNoteNamePath(noteNumber)


    if not FileSystem.FileExists(path) then
        return nil
    end


    return FileSystem.ReadFile(path)

end


-- ==========================================
-- GET DISPLAY NAME
-- ==========================================

function GetNoteDisplayName(noteNumber)

    local name =
        LoadNoteName(noteNumber)


    if name ~= nil and name ~= "" then

        return name

    end


    return "Note " .. tostring(noteNumber)

end


-- ==========================================
-- FIND FIRST EMPTY NOTE
-- ==========================================

function FindFirstEmptyNote()

    for i = 1, MAX_NOTES do

        if not NoteExists(i) then

            return i

        end

    end


    return -1

end


-- ==========================================
-- NOTE LIST
-- ==========================================

function BuildNoteList()

    local list = {}


    for i = 1, MAX_NOTES do

        if NoteExists(i) then

            table.insert(
                list,
                GetNoteDisplayName(i)
            )

        else

            table.insert(
                list,
                "Note " ..
                tostring(i) ..
                " (Empty)"
            )

        end

    end


    return list

end


-- ==========================================
-- SELECT NOTE
-- ==========================================

function SelectNote()

    local noteList =
        BuildNoteList()


    local dialogBox =
        Script.ShowPopupList(
            "AURORA NOTES XL",
            "Select a note",
            noteList
        )


    if dialogBox == nil then

        return -1

    end


    if dialogBox.Canceled then

        return -1

    end


    return dialogBox.Selected.Key

end


-- ==========================================
-- MAIN
-- ==========================================

function main()

    while true do

        local selectedMenuOption =
            ShowMainMenu()


        if selectedMenuOption == -1 then

            return

        end


        if selectedMenuOption ==
            MainMenuOption_New then

            NewNote()


        elseif selectedMenuOption ==
            MainMenuOption_View then

            ViewNotes()


        elseif selectedMenuOption ==
            MainMenuOption_Edit then

            EditNote()


        elseif selectedMenuOption ==
            MainMenuOption_Delete then

            DeleteNote()


        elseif selectedMenuOption ==
            MainMenuOption_SearchViewer then

            SearchAndTextViewer()


        elseif selectedMenuOption ==
            MainMenuOption_Info then

            NoteInfo()

        end

    end

end


-- ==========================================
-- SHOW MAIN MENU
-- ==========================================

function ShowMainMenu()

    local dialogBox =
        Script.ShowPopupList(
            scriptTitle,
            "Select an option",
            MainMenu
        )


    if dialogBox == nil then

        return -1

    end


    if not dialogBox.Canceled then

        return dialogBox.Selected.Key

    end


    return -1

end


-- ==========================================
-- NEW NOTE
-- ==========================================

function NewNote()

    local noteNumber =
        FindFirstEmptyNote()


    if noteNumber == -1 then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "All " ..
            tostring(MAX_NOTES) ..
            " note slots are full.",
            "OK"
        )

        return

    end


    -- ======================================
    -- NOTE NAME
    -- ======================================

    local nameResult =
        Script.ShowKeyboard(
            "AURORA NOTES XL",
            "Write the note name:",
            "",
            0
        )


    if nameResult == nil then

        return

    end


    if nameResult.Canceled then

        return

    end


    local noteName =
        nameResult.Buffer or ""


    if noteName == "" then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "The note name is empty.",
            "OK"
        )

        return

    end


    -- ======================================
    -- NOTE CONTENT
    -- ======================================

    local result =
        Script.ShowKeyboard(
            "AURORA NOTES XL",
            "Write your note:",
            "",
            0
        )


    if result == nil then

        return

    end


    if result.Canceled then

        return

    end


    local text =
        result.Buffer or ""


    if text == "" then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "The note is empty.",
            "OK"
        )

        return

    end


    -- ======================================
    -- SAVE CONTENT
    -- ======================================

    local saved =
        SaveNote(
            noteNumber,
            text
        )


    if not saved then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "Could not save the note.",
            "OK"
        )

        return

    end


    -- ======================================
    -- SAVE NAME
    -- ======================================

    local nameSaved =
        SaveNoteName(
            noteNumber,
            noteName
        )


    if not nameSaved then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "The note content was saved,\n" ..
            "but the name could not be saved.",
            "OK"
        )

        return

    end


    Script.ShowMessageBox(
        "AURORA NOTES XL",
        "\"" ..
        noteName ..
        "\" saved successfully!",
        "OK"
    )

end


-- ==========================================
-- VIEW NOTES
-- ==========================================

function ViewNotes()

    local noteNumber =
        SelectNote()


    if noteNumber == -1 then

        return

    end


    local note =
        LoadNote(noteNumber)


    if note == nil or note == "" then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "This note is empty.",
            "OK"
        )

        return

    end


    local noteName =
        GetNoteDisplayName(noteNumber)


    Script.ShowMessageBox(
        noteName,
        "\n" .. note,
        "OK"
    )

end


-- ==========================================
-- EDIT NOTE
-- ==========================================

function EditNote()

    local noteNumber =
        SelectNote()


    if noteNumber == -1 then

        return

    end


    local oldNote =
        LoadNote(noteNumber)


    if oldNote == nil or oldNote == "" then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "This note is empty.\n\nCreate it first.",
            "OK"
        )

        return

    end


    -- ======================================
    -- EDIT MENU
    -- ======================================

    local dialogBox =
        Script.ShowPopupList(
            "EDIT NOTE",
            GetNoteDisplayName(noteNumber),
            EditMenu
        )


    if dialogBox == nil then

        return

    end


    if dialogBox.Canceled then

        return

    end


    local selectedOption =
        dialogBox.Selected.Key


    -- ======================================
    -- EDIT NAME
    -- ======================================

    if selectedOption ==
        EditMenuOption_Name then

        local oldName =
            GetNoteDisplayName(noteNumber)


        local result =
            Script.ShowKeyboard(
                "EDIT NOTE NAME",
                "Edit note name:",
                oldName,
                0
            )


        if result == nil then

            return

        end


        if result.Canceled then

            return

        end


        local newName =
            result.Buffer or ""


        if newName == "" then

            Script.ShowMessageBox(
                "AURORA NOTES XL",
                "The note name is empty.",
                "OK"
            )

            return

        end


        local saved =
            SaveNoteName(
                noteNumber,
                newName
            )


        if saved then

            Script.ShowMessageBox(
                "AURORA NOTES XL",
                "Note name updated successfully!",
                "OK"
            )

        else

            Script.ShowMessageBox(
                "AURORA NOTES XL",
                "Could not update the note name.",
                "OK"
            )

        end


    -- ======================================
    -- EDIT CONTENT
    -- ======================================

    elseif selectedOption ==
        EditMenuOption_Content then

        local result =
            Script.ShowKeyboard(
                "EDIT NOTE",
                "Edit your note:",
                oldNote,
                0
            )


        if result == nil then

            return

        end


        if result.Canceled then

            return

        end


        local newText =
            result.Buffer or ""


        if newText == "" then

            Script.ShowMessageBox(
                "AURORA NOTES XL",
                "The note is empty.",
                "OK"
            )

            return

        end


        local saved =
            SaveNote(
                noteNumber,
                newText
            )


        if saved then

            Script.ShowMessageBox(
                "AURORA NOTES XL",
                "Note content updated successfully!",
                "OK"
            )

        else

            Script.ShowMessageBox(
                "AURORA NOTES XL",
                "Could not update the note.",
                "OK"
            )

        end

    end

end


-- ==========================================
-- DELETE NOTE
-- ==========================================

function DeleteNote()

    local noteNumber =
        SelectNote()


    if noteNumber == -1 then

        return

    end


    local notePath =
        GetNotePath(noteNumber)


    local namePath =
        GetNoteNamePath(noteNumber)


    if not FileSystem.FileExists(notePath) then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "This note is already empty.",
            "OK"
        )

        return

    end


    local noteName =
        GetNoteDisplayName(noteNumber)


    local result =
        Script.ShowMessageBox(
            "DELETE NOTE",
            "Delete \"" ..
            noteName ..
            "\"?",
            "Yes",
            "No"
        )


    if result == nil or
       result.Canceled then

        return

    end


    if result.Button == 1 then

        local deleted =
            FileSystem.DeleteFile(notePath)


        if FileSystem.FileExists(namePath) then

            FileSystem.DeleteFile(namePath)

        end


        if deleted then

            Script.ShowMessageBox(
                "AURORA NOTES XL",
                "\"" ..
                noteName ..
                "\" deleted.",
                "OK"
            )

        else

            Script.ShowMessageBox(
                "AURORA NOTES XL",
                "Could not delete the note.",
                "OK"
            )

        end

    end

end


-- ==========================================
-- SEARCH & TEXT VIEWER
-- ==========================================

function SearchAndTextViewer()

    local dialogBox =
        Script.ShowPopupList(
            "SEARCH & TEXT VIEWER",
            "Select an option",
            SearchViewerMenu
        )


    if dialogBox == nil then

        return

    end


    if dialogBox.Canceled then

        return

    end


    local selectedOption =
        dialogBox.Selected.Key


    if selectedOption ==
        SearchViewerOption_Search then

        SearchNotes()


    elseif selectedOption ==
        SearchViewerOption_Text then

        TextViewer()

    end

end


-- ==========================================
-- SEARCH NOTES
-- ==========================================

function SearchNotes()

    local result =
        Script.ShowKeyboard(
            "SEARCH NOTES",
            "Enter a search word:",
            "",
            0
        )


    if result == nil then

        return

    end


    if result.Canceled then

        return

    end


    local query =
        result.Buffer or ""


    if query == "" then

        Script.ShowMessageBox(
            "SEARCH NOTES",
            "Search text is empty.",
            "OK"
        )

        return

    end


    local results = {}
    local resultNumbers = {}


    for i = 1, MAX_NOTES do

        if NoteExists(i) then

            local note =
                LoadNote(i) or ""


            local name =
                GetNoteDisplayName(i)


            local lowerName =
                string.lower(name)


            local lowerNote =
                string.lower(note)


            local lowerQuery =
                string.lower(query)


            local foundInName =
                string.find(
                    lowerName,
                    lowerQuery,
                    1,
                    true
                )


            local foundInNote =
                string.find(
                    lowerNote,
                    lowerQuery,
                    1,
                    true
                )


            if foundInName or foundInNote then

                table.insert(
                    results,
                    name
                )


                table.insert(
                    resultNumbers,
                    i
                )

            end

        end

    end


    -- ======================================
    -- NO RESULTS
    -- ======================================

    if #results == 0 then

        Script.ShowMessageBox(
            "SEARCH NOTES",
            "No notes found for:\n\n" ..
            query,
            "OK"
        )

        return

    end


    -- ======================================
    -- SHOW RESULTS
    -- ======================================

    local dialogBox =
        Script.ShowPopupList(
            "SEARCH NOTES",
            "Results for: " .. query,
            results
        )


    if dialogBox == nil then

        return

    end


    if dialogBox.Canceled then

        return

    end


    local selectedIndex =
        dialogBox.Selected.Key


    local noteNumber =
        resultNumbers[selectedIndex]


    if noteNumber == nil then

        return

    end


    local note =
        LoadNote(noteNumber)


    if note == nil or note == "" then

        return

    end


    Script.ShowMessageBox(
        GetNoteDisplayName(noteNumber),
        "\n" .. note,
        "OK"
    )

end


-- ==========================================
-- COUNT LINES
-- ==========================================

function CountLines(text)

    if text == nil or text == "" then

        return 0

    end


    local count = 1


    for _ in string.gmatch(
        text,
        "\n"
    ) do

        count = count + 1

    end


    return count

end


-- ==========================================
-- NOTE INFO
-- ==========================================

function NoteInfo()

    local noteNumber =
        SelectNote()


    if noteNumber == -1 then

        return

    end


    local note =
        LoadNote(noteNumber)


    if note == nil or note == "" then

        Script.ShowMessageBox(
            "AURORA NOTES XL",
            "This note is empty.",
            "OK"
        )

        return

    end


    local noteName =
        GetNoteDisplayName(noteNumber)


    local characterCount =
        string.len(note)


    local lineCount =
        CountLines(note)


    local information =
        "Name: " ..
        noteName ..
        "\n\n" ..

        "Note Slot: " ..
        tostring(noteNumber) ..
        " / " ..
        tostring(MAX_NOTES) ..
        "\n\n" ..

        "Characters: " ..
        tostring(characterCount) ..
        "\n\n" ..

        "Lines: " ..
        tostring(lineCount)


    Script.ShowMessageBox(
        "NOTE INFO",
        information,
        "OK"
    )

end


-- ==========================================
-- TEXT VIEWER
-- ==========================================

function TextViewer()

    local fileResult =
        Script.ShowKeyboard(
            "TEXT VIEWER",
            "Enter the text file path:",
            "",
            0
        )


    if fileResult == nil then

        return

    end


    if fileResult.Canceled then

        return

    end


    local path =
        fileResult.Buffer or ""


    if path == "" then

        Script.ShowMessageBox(
            "TEXT VIEWER",
            "No file path entered.",
            "OK"
        )

        return

    end


    -- ======================================
    -- CHECK FILE
    -- ======================================

    if not FileSystem.FileExists(path) then

        Script.ShowMessageBox(
            "TEXT VIEWER",
            "File not found.\n\n" ..
            path,
            "OK"
        )

        return

    end


    -- ======================================
    -- READ FILE
    -- ======================================

    local text =
        FileSystem.ReadFile(path)


    if text == nil then

        Script.ShowMessageBox(
            "TEXT VIEWER",
            "Could not read the file.",
            "OK"
        )

        return

    end


    if text == "" then

        Script.ShowMessageBox(
            "TEXT VIEWER",
            "The file is empty.",
            "OK"
        )

        return

    end


    -- ======================================
    -- DISPLAY
    -- ======================================

    Script.ShowMessageBox(
        "TEXT VIEWER",
        "\n" .. text,
        "OK"
    )

end