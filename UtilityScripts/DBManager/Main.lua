scriptTitle = "Aurora Database Manager"
scriptAuthor = "EmiMods"
scriptVersion = 1.0
scriptDescription = "Browse and manage Aurora's databases"
scriptIcon = "icon.png"
scriptPermissions = { "sql" }

-- Unfortunately I don't know the secondary database alias for Settings (Content.db is primary) and we cannot use commands, so manually listing tables and DB
TableContentHeader = "--- Content.db Tables ---"
TableSettingsHeader = "--- Settings.db Tables ---"
TableSubitemPadding = "      ";
Tables = { 
 -- { {table}, {columns} }
    { {TableContentHeader}, {} },
    { {TableSubitemPadding .. "ContentItems"}, { "Id","Directory","Executable","TitleId","MediaId","BaseVersion","DiscNum","DiscsInSet","TitleName","Description","Publisher","Developer","LiveRating","LiveRaters","ReleaseDate","GenreFlag","ContentFlags","Hash","GameCapsOnline","GameCapsOffline","GameCapsFlags","FileType","ContentType","ContentGroup","DefaultGroup","DateAdded","FoundAtDepth","SystemLink","ScanPathId","CaseIndex"} },
    { {TableSubitemPadding .. "DvdCache"}, {"Id","Directory","Executable","TitleId","MediaId","BaseVersion","DiscNum","DiscsInSet","TitleName","Description","Publisher","Developer","LiveRating","LiveRaters","ReleaseDate","GenreFlag","ContentFlags","Hash","GameCapsOnline","GameCapsOffline","GameCapsFlags","FileType","ContentType","ContentGroup","DefaultGroup","DateAdded","FoundAtDepth","SystemLink","ScanPathId","CaseIndex"} },
    { {TableSubitemPadding .. "MountedDevices"}, {"DeviceId","DeviceName","VirtualRoot","MountPoint"} },
    { {TableSubitemPadding .. "TitleUpdates"}, {"Id","DisplayName","FileName","LiveDeviceId","LivePath","TitleId","MediaId","BaseVersion","Version","Hash","BackupPath","FileSize"} },
    { {TableSettingsHeader}, {} },
    { {TableSubitemPadding .. "ActiveTitleUpdates"}, {"Id","TitleUpdateId"} },
    { {TableSubitemPadding .. "Profiles"}, {"Id","Gametag","Xuid"} },
    { {TableSubitemPadding .. "QuickViews"}, {"Id","DisplayName","SortMethod","FilterMethod","Flags","CreatorXUID","OrderIndex","IconHash"} },
    { {TableSubitemPadding .. "RSSFeeds"}, {"Id","Url","Enabled"} },
    { {TableSubitemPadding .. "ScanPaths"}, {"Id","Path","DeviceId","Depth","ScriptData","OptionsFlag"} },
    { {TableSubitemPadding .. "SystemSettings"}, {"Id","Name","Value"} },
    { {TableSubitemPadding .. "TitleSettings"}, {"Id","ContentId","SettingValue"} },
    { {TableSubitemPadding .. "Trainers"}, {"Id","Hash","TitleId","Value"} },
    { {TableSubitemPadding .. "UserFavorites"}, {"Id","ContentId","ProfileId"} },
    { {TableSubitemPadding .. "UserHidden"}, {"Id","ContentId","ProfileId"} },
    { {TableSubitemPadding .. "UserRecentGames"}, {"Id","DateTime","ContentId","ProfileId"} },
    { {TableSubitemPadding .. "UserSettings"}, {"Id","Name","Value","ProfileId"} }
}

CurrentBuilderQuery = ""
LastEntry = ""

SqlSyntax = {
    "SELECT",
    "SELECT *",
    "UPDATE",
    "INSERT",
    "INTO",
    "DELETE",
    "DISTINCT",
    "AS",
    "SET",
    "FROM",
    "WHERE",
    "AND",
    "OR",
    "ANY",
    "ALL",
    "NOT",
    "LIKE",
    "CASE",
    "WHEN",
    "THEN",
    "ELSE",
    "END",
    "JOIN",
    "LEFT JOIN",
    "RIGHT JOIN",
    "CROSS JOIN",
    "UNION",
    "ON",
    "DO",
    "BETWEEN",
    "IN",
    "ORDER BY",
    "GROUP BY",
    "HAVING",
    "ASC",
    "DESC",
    "LIMIT",
    "RETURNING",
    "NULL",
    "NOTHING",
    "EXCEPT",
    "VALUES(",
    "CONFLICT(",
    "SUM(",
    "AVG(",
    "MAX(",
    "MIN(",
    "UPPER(",
    "LOWER(",
    "SUBSTR(",
    "GROUP_CONCAT("
}

Keyboard = {
    "SPACE",
    ",",
    "'",
    "(",
    ")",
    ".",
    "=",
    "+",
    "-",
    "*",
    "/",
    "%",
    ">",
    "<",
    ">=",
    ">=",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "\"",
    "-",
    "_",
    ":",
    ";",
    "{",
    "}",
    "$",
    "@",
    "!",
    "#",
    "^",
    "\\";
    "~",
    "`",
    "|",
    "&",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
}

MainMenu = {
    "Manually Query Databases",
    "View Table (All Entries)"
}

QueryBuilderMenu = {
    "Show SQL Syntax",
    "Show Keyboard",
    "Show Tables",
    "Show Column By Table",
    "Show Full Query",
    "Delete Last Entry",
    "Backspace",
    "",
    "Clear Query",
    "",
    "Execute Query"
}

MainMenuOption_QueryBuilder = 1
MainMenuOption_ViewTable = 2

-- Main entry point to script
function main()
    ResetToMainMenu()
end

-- Return to start of the application
function ResetToMainMenu()
    -- Show Main Menu
    local selectedMenuOption = ShowMainMenu();

    if selectedMenuOption == MainMenuOption_QueryBuilder then     -- User selected "Manually Query Databases"
        ShowQueryBuilder()
    elseif selectedMenuOption == MainMenuOption_ViewTable then     -- User selected "View Table (All Entries)"
        ShowTable(PromptTableSelect())
    end
    -- User canceled
end

-- Display Main Menu and return selected option's index, or -1 if cancelled
function ShowMainMenu()
    local dialogBox = Script.ShowPopupList(scriptTitle, "Error", MainMenu)
    if not dialogBox.Canceled then
        return dialogBox.Selected.Key
    end
    
    return -1
end

-- Menu for user to build and execute queries
function ShowQueryBuilder()
    -- Show primary Query Builder menu
    local dialogBox = Script.ShowPopupList("Query: " .. GetFittedCurrentBuilderQuery(), "Error", QueryBuilderMenu)
    local quit = false
    if not dialogBox.Canceled then
        local selected = dialogBox.Selected.Value

        if selected == QueryBuilderMenu[1] then     -- "Show SQL Syntax"
            local selectedSyntax
            while selectedSyntax ~= -1 do   -- Keep refreshing screen for input until user cancels
                selectedSyntax = PromptSelectFromArr(SqlSyntax, "Query: " .. GetFittedCurrentBuilderQuery())
                if selectedSyntax ~= -1 then
                    local toInsert = SqlSyntax[selectedSyntax]
                    if toInsert:sub(-1) ~= "(" then
                        toInsert = toInsert .. " "
                    end
                    LastEntry = toInsert
                    CurrentBuilderQuery = CurrentBuilderQuery .. toInsert
                end
            end
        elseif selected == QueryBuilderMenu[2] then -- "Show Keyboard"
            local selectedKey
            while selectedKey ~= -1 do   -- Keep refreshing screen for input until user cancels
                selectedKey = PromptSelectFromArr(Keyboard, "Query: " .. GetFittedCurrentBuilderQuery())
                if selectedKey ~= -1 then
                    local toInsert = Keyboard[selectedKey]
                    if toInsert == "SPACE" then
                        toInsert = " "
                    end
                    LastEntry = toInsert
                    CurrentBuilderQuery = CurrentBuilderQuery .. toInsert
                end
            end
        elseif selected == QueryBuilderMenu[3] then -- "Show Tables"
            local selectedTableKey = PromptTableSelect()
            if selectedTableKey ~= -1 then
                local selectedTableName = StripSubitemPadding(Tables[selectedTableKey][1][1]) .. " "    -- Append space to end of table name for query insert
                
                LastEntry = selectedTableName
                CurrentBuilderQuery = CurrentBuilderQuery .. selectedTableName
            end
        elseif selected == QueryBuilderMenu[4] then -- "Show Column By Table"
            local selectedTableKey = PromptTableSelect()
            if selectedTableKey ~= -1 then
                local selectedTableName = StripSubitemPadding(Tables[selectedTableKey][1][1])
                local iDialogBox = Script.ShowPopupList(selectedTableName .. " columns", "Error", Tables[selectedTableKey][2])
                if not iDialogBox.Canceled then
                    local selectedColumnName = iDialogBox.Selected.Value .. " "
                    LastEntry = selectedColumnName
                    CurrentBuilderQuery = CurrentBuilderQuery .. selectedColumnName
                end
            end
        elseif selected == QueryBuilderMenu[5] then -- "Show Full Query"
            Script.ShowMessageBox("Query", CurrentBuilderQuery, "Back")
        elseif selected == QueryBuilderMenu[6] then -- "Delete Last Entry"
            if LastEntry ~= "" then
                -- Find the index of the last occurrence of LastEntry
                local lastEntryStartIndex = #CurrentBuilderQuery - (#LastEntry - CurrentBuilderQuery:reverse():find(LastEntry:reverse()))
                if lastEntryStartIndex then
                    -- Reconstruct string without the last occurrence
                    CurrentBuilderQuery = CurrentBuilderQuery:sub(1, lastEntryStartIndex - 1)
                end
                LastEntry = ""
            end
        elseif selected == QueryBuilderMenu[7] then -- "Backspace"
            CurrentBuilderQuery = CurrentBuilderQuery:sub(1, #CurrentBuilderQuery - 1)
        elseif selected == QueryBuilderMenu[8] then -- ""
        elseif selected == QueryBuilderMenu[9] then -- "Clear Query"
            CurrentBuilderQuery = ""
        elseif selected == QueryBuilderMenu[10] then -- ""
        elseif selected == QueryBuilderMenu[11] then -- "Execute Query"
            -- Determine if we need to return data
            if string.find(CurrentBuilderQuery:upper(), " RETURNING ") or string.find(CurrentBuilderQuery:upper(), "SELECT ") then  -- Data return needed
                local queryResponse = Sql.ExecuteFetchRows(CurrentBuilderQuery)    -- Execute query
                for i, row in ipairs(queryResponse) do
                    local displayRows = {}
                    for key, value in pairs(row) do -- Populate column: value pairs for display rows in popup list
                        if value ~= nil then
                            displayRows[#displayRows+1] = key .. ": " .. value
                        else
                            displayRows[#displayRows+1] = key .. ": Null"
                        end
                    end
                    -- Display db entry
                    local dialogBox = Script.ShowPopupList("Entry " .. i .. " of " .. #queryResponse, "Error", displayRows)
                    if dialogBox.Canceled then
                        break
                    end
                end
            else    -- Data return not needed, just execute
                Sql.Execute(CurrentBuilderQuery)
                Script.ShowMessageBox("Done", "Query executed successfully", "Ok")
                ResetToMainMenu()
                return
            end
        end
        
        ShowQueryBuilder()  -- Refresh Query Builder after selection
        return
    end

    ResetToMainMenu()  -- User canceled
end

-- Prompts user to select a table for browsing and returns selected index, returns -1 on cancel
function PromptTableSelect()
    local selectedTable = ""
    local selectedTableKey = -1
    local dialogBox
    -- Wait for user to select VALID table option
    while selectedTable == "" do
        dialogBox = Script.ShowPopupList("Database Browser", "None found.", GetTableNames())
        if dialogBox.Canceled then
           selectedTable = "Canceled"
        elseif dialogBox.Selected.Value ~= TableContentHeader and dialogBox.Selected.Value ~= TableSettingsHeader then  -- Filter out database name display headers
            selectedTable = dialogBox.Selected.Value
            selectedTableKey = dialogBox.Selected.Key
        end
    end

    return selectedTableKey
end

-- Prompts the user to select from a given array in a popup list, returns -1 on cancel
function PromptSelectFromArr(arr, title)
    local dialogBox = Script.ShowPopupList(title, "Error", arr)
    local ret = -1
    if not dialogBox.Canceled then
        ret = dialogBox.Selected.Key
    end

    return ret
end

-- Display selected table in popup list
function ShowTable(key)
    -- Main menu return
    if key <= 0 then
        ResetToMainMenu()
    else
        -- Populate table name, columns, and database entries
        local rows = {} -- Rows in the database table
        local tableName = StripSubitemPadding(Tables[key][1][1])
        local columns = Tables[key][2]
        for i, row in pairs(Sql.ExecuteFetchRows("SELECT * FROM " .. tableName .. " ORDER BY " .. columns[1] .. " ASC")) do   -- Safe to assume first column will always be primary key
            rows[i] = row
        end


        -- Iterate main menu button and database entries for selected table/option and display
        for i, row in ipairs(rows) do
            -- Populate rows in popup list to display data by column
            local displayRows = {}
            for j, column in ipairs(columns) do
                if row[column] == nil then
                    displayRows[j] = column .. ": Null"
                else
                    displayRows[j] = column .. ": " .. row[column]
                end
            end

            -- Display data for entry
            local dialogBox = Script.ShowPopupList("Table: " .. tableName .. " (" .. i .. " of " .. #rows .. ")", "None found.", displayRows)
            if dialogBox.Canceled then
                break
            end
        end

        if #rows == 0 then
            Script.ShowMessageBox("Empty table", "No records found.", "OK")
        end

        ResetToMainMenu()
    end
end

-- Returns an array of accessible table names
function GetTableNames()
    local ret = {}
    for i, innerTable in ipairs(Tables) do
        ret[i] = innerTable[1][1]
    end
    return ret
end

 -- Remove display padding and return string
function StripSubitemPadding(stringToStrip)
    return string.sub(stringToStrip, string.len(TableSubitemPadding) + 1, string.len(stringToStrip));
end

-- Returns the current builder query trimmed to fit into a title box. Left-side trim.
function GetFittedCurrentBuilderQuery()
    if #CurrentBuilderQuery > 45 then
        return ".." .. CurrentBuilderQuery:sub(#CurrentBuilderQuery - 43, #CurrentBuilderQuery)
    else
        return CurrentBuilderQuery
    end
end