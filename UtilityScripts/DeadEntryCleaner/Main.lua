scriptTitle = "Dead Entry Cleaner (BETA)"
scriptAuthor = "Eduardo Henrique/Channel Edu Dicas e Gameplay"
scriptVersion = "1.0"
scriptDescription = "Removes ghost entries from Aurora (ContentItems). Does not alter games, DLCs, or TUs. May require a re-scan."

scriptPermissions = { "filesystem", "sql" }
scriptIcon = "icon.png"

--------------------------------------------------
-- COUNTERS
--------------------------------------------------

local removedCount = 0
local failedCount = 0
local scannedCount = 0
local deadCount = 0

--------------------------------------------------
-- LOG SYSTEM (USING SELECTED DRIVE)
--------------------------------------------------

local LOG_PATH = nil
local LOG_FILE = nil

--------------------------------------------------
-- SAFE DATE/TIME
--------------------------------------------------

function getSafeDateTime()

    local ok, result = pcall(function()
        return os.date("%d/%m/%Y %H:%M:%S")
    end)

    if ok and result then
        return result
    end

    return "DATE_UNAVAILABLE"
end

--------------------------------------------------
-- HELPERS
--------------------------------------------------

function fileExists(path)
    local ok = false
    pcall(function()
        if FileSystem.FileExists(path) then ok = true end
    end)
    return ok
end

function exactMatch(text, keyword)
    text = safeLower(text or "")
    keyword = safeLower(keyword or "")

    return text == keyword
end

function dirExists(path)
    local ok = false
    pcall(function()
        if FileSystem.DirectoryExists(path) then ok = true end
    end)
    return ok
end

function getFileCount(path)
    local count = 0
    pcall(function()
        local files = FileSystem.GetFiles(path)
        if files then count = #files end
    end)
    return count
end

function normalizePath(path)
    if not path then return "" end
    return string.gsub(tostring(path), "\\\\", "\\")
end

function safeLower(text)
    if not text then return "" end
    return string.lower(tostring(text))
end

function isValidTitleId(id)
    if not id then return false end
    if string.len(id) ~= 8 then return false end
    return true
end

--------------------------------------------------
-- DRIVE SELECTION (IMPROVED UX)
--------------------------------------------------

function selectDrive()

    local drives = {}
    local dialog = {}

    local list = FileSystem.GetDrives(false)

    for i, d in ipairs(list) do

        local mount = d["MountPoint"] or "UNKNOWN"
        local serial = d["Serial"] or "UNKNOWN"

        local label = ""

        if string.find(safeLower(mount), "hdd") then
            label = "HDD (Internal Storage)"
        elseif string.find(safeLower(mount), "usb") then
            label = "USB (External Device)"
        else
            label = "Storage Device (" .. mount .. ")"
        end

        drives[i] = {
            mount = mount,
            serial = serial
        }

        dialog[i] =
            label ..
            " -> " .. mount ..
            " | Serial: " .. string.sub(serial, 1, 10) .. "..."
    end

    local result = Script.ShowPopupList(
        "SELECT STORAGE TO CLEAN",
        "No storage devices found.",
        dialog
    )

    if result.Canceled then
        return nil
    end

    return drives[result.Selected.Key]
end

--------------------------------------------------
-- SIMPLE GOD CHECK
--------------------------------------------------

local GOD_FOLDERS = {
    "00007000","00004000","000B0000","00000002"
}

function isValidGOD(directory)

    if not dirExists(directory) then return false end

    for i = 1, #GOD_FOLDERS do

        local path = directory .. "\\" .. GOD_FOLDERS[i]

        if dirExists(path) then
            if getFileCount(path) > 0 then
                return true
            end
        end
    end

    return false
end

--------------------------------------------------
-- ADVANCED PROTECTION (ACCIDENTAL REMOVAL PREVENTION)
--------------------------------------------------

function isProtectedEntry(item)

    local title = safeLower(item.TitleName or "")
    local directory = safeLower(item.Directory or "")
    local executable = safeLower(item.Executable or "")
    local contentType = tonumber(item.ContentType or 0)
    local titleId = tostring(item.TitleId or "")

    --------------------------------------------------
    -- DASHBOARDS / SYSTEM
    --------------------------------------------------

    if string.find(title, "aurora") then return true end
    if string.find(title, "xexmenu") then return true end
    if string.find(title, "dashlaunch") then return true end
    if string.find(title, "dash launch") then return true end
    if string.find(title, "freestyle") then return true end

    -- short names = exactMatch
    if exactMatch(title, "fsd") then return true end

    if string.find(title, "quickboot") then return true end
    if string.find(title, "xell") then return true end
    if string.find(title, "nand flasher") then return true end
    if string.find(title, "simple nand flasher") then return true end
    if string.find(title, "rawflash") then return true end
    if string.find(title, "xebuild") then return true end

    --------------------------------------------------
    -- IMPORTANT UTILITIES
    --------------------------------------------------

    if string.find(title, "xm360") then return true end
    if string.find(title, "nxe2god") then return true end
    if string.find(title, "god unlocker") then return true end
    if string.find(title, "yarisswap") then return true end
    if string.find(title, "title update manager") then return true end
    if string.find(title, "tu manager") then return true end
    if string.find(title, "dlc manager") then return true end
    if string.find(title, "profile manager") then return true end
    if string.find(title, "avatar unlocker") then return true end
    if string.find(title, "kv checker") then return true end
    if string.find(title, "cpu key") then return true end

    --------------------------------------------------
    -- IMPORTANT EMULATORS
    --------------------------------------------------

    if string.find(title, "retroarch") then return true end
    if string.find(title, "fbanext") then return true end
    if string.find(title, "fba next") then return true end
    if string.find(title, "final burn") then return true end
    if string.find(title, "mame") then return true end
    if string.find(title, "snes360") then return true end
    if string.find(title, "genesis") then return true end
    if string.find(title, "vba360") then return true end
    if string.find(title, "visual boy") then return true end
    if string.find(title, "neocd") then return true end
    if string.find(title, "surreal64") then return true end
    if string.find(title, "dosbox") then return true end
    if string.find(title, "scummvm") then return true end

    --------------------------------------------------
    -- SERVICES / NETWORK / PLUGINS
    --------------------------------------------------

    -- short/generic names = exactMatch
    if exactMatch(title, "proto") then return true end
    if string.find(title, "xbdm") then return true end
    if exactMatch(title, "jrpc") then return true end
    if string.find(title, "ftp server") then return true end
    if exactMatch(title, "link") then return true end
    if exactMatch(title, "unity") then return true end
    if string.find(title, "trainer launcher") then return true end
    if string.find(title, "plugin loader") then return true end
    if string.find(title, "stealth") then return true end
    if string.find(title, "xbls") then return true end
    if exactMatch(title, "ninja") then return true end
    if exactMatch(title, "cipher") then return true end
    if exactMatch(title, "teapot") then return true end

    --------------------------------------------------
    -- DIRECTORY PROTECTION (VERY IMPORTANT)
    --------------------------------------------------

    if string.find(directory, "c0de9999") then return true end
    if string.find(directory, "aurora") then return true end
    if string.find(directory, "freestyle") then return true end
    if string.find(directory, "dashlaunch") then return true end
    if string.find(directory, "xexmenu") then return true end
    if string.find(directory, "dash launch") then return true end
    if string.find(directory, "emuladores") then return true end
    if string.find(directory, "homebrew") then return true end
    if string.find(directory, "apps") then return true end
    if string.find(directory, "tools") then return true end

    --------------------------------------------------
    -- EXECUTABLE PROTECTION
    --------------------------------------------------

    if string.find(executable, "aurora") then return true end
    if string.find(executable, "xexmenu") then return true end
    if string.find(executable, "freestyle") then return true end
    if string.find(executable, "dashlaunch") then return true end
    if string.find(executable, "fbanext") then return true end
    if string.find(executable, "retroarch") then return true end

    --------------------------------------------------
    -- CRITICAL CONTENT TYPES
    --------------------------------------------------

    -- XeXMenu LIVE
    if contentType == 524288 then return true end

    --------------------------------------------------
    -- SPECIAL TITLEIDS
    --------------------------------------------------

    if titleId == "-1059153511" then return true end -- QuickBoot
    if titleId == "C0DE9999" then return true end

    --------------------------------------------------
    -- EXTRA SAFETY
    --------------------------------------------------

    if title == "" and directory == "" then
        return true
    end

    return false
end

--------------------------------------------------
-- SAFE DETECTION
--------------------------------------------------

function isDeadEntry(item, selectedMount)

    local directory = normalizePath(item.Directory or "")
    local executable = normalizePath(item.Executable or "")
    local contentType = tonumber(item.ContentType or 0)
    local titleId = tostring(item.TitleId or "")

    --------------------------------------------------
    -- EMPTY DIRECTORY
    --------------------------------------------------

    if directory == "" then
    return true, "EMPTY_DIRECTORY"
end

    --------------------------------------------------
    -- PROTECTED
    --------------------------------------------------

    if isProtectedEntry(item) then
        return false, "PROTECTED_ENTRY"
    end

--------------------------------------------------
-- CHECK IF DIRECTORY DOES NOT EXIST (ESSENTIAL)
--------------------------------------------------

if not dirExists(directory) then
    return true, "DIRECTORY_NOT_FOUND"
end

    --------------------------------------------------
    -- MULTI DISC
    --------------------------------------------------

    if tonumber(item.DiscsInSet or 1) > 1 then
        return false, "MULTI_DISC_PROTECTED"
    end

    --------------------------------------------------
    -- INVALID TITLEID
    --------------------------------------------------

    if not isValidTitleId(titleId) then
        return false, "INVALID_TITLEID"
    end

    --------------------------------------------------
    -- XEX CHECK
    --------------------------------------------------

    if executable ~= "" and string.sub(safeLower(executable), -4) == ".xex" then

        if fileExists(directory .. "\\" .. executable) then
            return false, "XEX_EXISTS"
        end

        if fileExists(directory .. "\\default.xex") then
            return false, "DEFAULT_XEX_EXISTS"
        end

        if getFileCount(directory) > 0 then
            return false, "DIRECTORY_HAS_FILES"
        end

        return true, "XEX_MISSING"
    end

    --------------------------------------------------
    -- XBE CHECK
    --------------------------------------------------

if executable ~= "" and string.sub(safeLower(executable), -4) == ".xbe" then

    if fileExists(directory .. "\\" .. executable) then
        return false, "XBE_EXISTS"
    end

    if fileExists(directory .. "\\default.xbe") then
        return false, "DEFAULT_XBE_EXISTS"
    end

    if getFileCount(directory) > 0 then
        return false, "DIRECTORY_HAS_FILES"
    end

    return true, "XBE_MISSING"
end

    --------------------------------------------------
    -- GOD CHECK
    --------------------------------------------------

    if contentType == 28672 then

        if isValidGOD(directory) then
            return false, "VALID_GOD"
        end

        return true, "INVALID_GOD"
    end

    --------------------------------------------------
    -- FALLBACK
    --------------------------------------------------

    if getFileCount(directory) > 0 then
        return false, "FALLBACK_DIRECTORY_HAS_FILES"
    end

    return true, "FALLBACK_GHOST_ENTRY"
end

--------------------------------------------------
-- REMOVE
--------------------------------------------------

function removeContentItem(id)
    local ok = false
    pcall(function()
        Sql.Execute("DELETE FROM ContentItems WHERE Id = " .. tostring(id))
        ok = true
    end)
    return ok
end

--------------------------------------------------
-- MAIN
--------------------------------------------------

function main()

--------------------------------------------------
-- ENHANCED UX CHECKLIST
--------------------------------------------------

local confirmStart = Script.ShowMessageBox(
    "SAFETY CHECKLIST",
    "BEFORE CONTINUING:\n\n" ..

    "✔ Does not delete games from storage\n" ..
    "✔ Does not remove DLCs or Title Updates\n" ..
    "✔ Only removes invalid Aurora entries\n\n" ..

    "✔ The library can be rebuilt after a re-scan\n" ..
    "✔ You may need to re-scan paths after use\n\n" ..

    "✔ Database backup is recommended (not required)\n" ..
    "Common database locations:\n" ..
    "Data\\Databases\\content.db\n" ..
    "User\\Data\\Databases\\content.db\n\n" ..

    "Do you want to continue?",
    "Continue",
    "Cancel"
)

if confirmStart.Button ~= 1 then return end

    --------------------------------------------------
    -- DRIVE
    --------------------------------------------------

    local drive = selectDrive()
    if not drive then return end

    local selectedMount = drive.mount

    local confirmDrive = Script.ShowMessageBox(
        "CONFIRMATION",
        "Selected storage:\n" .. selectedMount .. "\n\n" ..
        "Cleaning will only be applied to the Aurora database.\nNo physical content will be modified.\nContinue?",
        "Yes",
        "Cancel"
    )

    if confirmDrive.Button ~= 1 then return end

--------------------------------------------------
-- SCAN
--------------------------------------------------

local rows = Sql.ExecuteFetchRows([[
    SELECT Id, Directory, Executable, TitleName, ContentType, DiscsInSet, TitleId
    FROM ContentItems
]])

if not rows then
    Script.ShowMessageBox("Error", "Failed to read database.", "OK")
    return
end

local deadItems = {}
local preview = ""

for i = 1, #rows do

    local item = rows[i]
    scannedCount = scannedCount + 1

    --------------------------------------------------
    -- Now isDeadEntry must return:
    -- return true/false, "REASON"
    --------------------------------------------------

    local ok, dead, reason = pcall(function()
        return isDeadEntry(item, selectedMount)
    end)

    --------------------------------------------------
    -- If an internal error occurred during analysis
    --------------------------------------------------

    if not ok then

    else

        if dead then

            deadCount = deadCount + 1
            table.insert(deadItems, item)

            if deadCount <= 20 then
                preview = preview ..
                    "- " .. (item.TitleName or "???") ..
                    " | Reason: " .. tostring(reason or "UNKNOWN") ..
                    "\n"
            end
        end
    end
end

if deadCount == 0 then

    Script.ShowMessageBox(
        "OK",
        "No ghost entries found.",
        "OK"
    )

    return
end

    --------------------------------------------------
    -- CONFIRMATION
    --------------------------------------------------

    local confirmRemove = Script.ShowMessageBox(
        "CONFIRM REMOVAL",
        "Found: " .. deadCount .. "\n\n" ..
        preview .. "\n\nRemove from the Aurora database?",
        "Remove",
        "Cancel"
    )

    if confirmRemove.Button ~= 1 then return end

    --------------------------------------------------
    -- REMOVAL
    --------------------------------------------------

for i = 1, #deadItems do

    if removeContentItem(deadItems[i].Id) then

        removedCount = removedCount + 1

    else

        failedCount = failedCount + 1

    end
end

    --------------------------------------------------
    -- FINISHED
    --------------------------------------------------

local restart = Script.ShowMessageBox(
    "COMPLETED",
    "Scanned: " .. scannedCount ..
    "\nRemoved: " .. removedCount ..
    "\nFailures: " .. failedCount ..
    "\n\nRestart Aurora to apply the changes?",
    "Yes",
    "No"
)

if restart.Button == 1 then
    Aurora.Restart()
else
    -- do nothing
end
end