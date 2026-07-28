scriptTitle = "Aurora Drive Fixer Smart"
scriptAuthor = "Eduardo Henrique/Canal Edu Dicas e Gameplay"
scriptVersion = 1.0
scriptDescription = "Fixes scanpaths and Title Updates after drive cloning, with intelligent and safe handling of duplicates."
scriptIcon = "icon.png"
scriptPermissions = { "filesystem", "sql" }

ExitTriggered = false

--------------------------------------------------
-- SELECT DRIVE (SERIAL)
--------------------------------------------------
function selectDrive()

    local drives = {}
    local dialog = {}

    for i, d in ipairs(FileSystem.GetDrives(false)) do
        drives[i] = {
            mount = d["MountPoint"],
            serial = d["Serial"]
        }

        dialog[i] =
            d["MountPoint"] ..
            " (Serial: " .. string.sub(d["Serial"], 1, 12) .. "...)"
    end

    local result = Script.ShowPopupList(
        "Select the drive where the games are located:",
        "No device found.",
        dialog
    )

    if result.Canceled then
        ExitTriggered = true
        return nil
    end

    return drives[result.Selected.Key]
end

--------------------------------------------------
-- ASK WHETHER TO SKIP SCANPATHS
--------------------------------------------------
function askSkipScanpaths()

    local confirm = Script.ShowMessageBox(
        "Scanpaths",
        "Do you also want to fix Scanpaths?\n\n(If not, only Title Updates will be fixed)",
        "Yes",
        "Only TUs"
    )

    return confirm.Button ~= 1
end

--------------------------------------------------
-- SCANPATHS
--------------------------------------------------
function fixScanpaths(newSerial)

    local rows = {}
    local dialog = ""

    for _, row in pairs(Sql.ExecuteFetchRows("SELECT id, path, deviceid FROM scanpaths ORDER BY id ASC") or {}) do
        if row["DeviceId"] ~= newSerial then
            table.insert(rows, row)

            dialog = dialog ..
                row["Path"] ..
                " (" ..
                string.sub(row["DeviceId"],1,6) ..
                " → " ..
                string.sub(newSerial,1,6) ..
                ")\n"
        end
    end

    if #rows == 0 then
        Script.ShowMessageBox("Scanpaths", "No scanpath needs to be changed.", "OK")
        return 0, 0
    end

    local confirm = Script.ShowMessageBox(
        "Scanpaths found",
        dialog,
        "Fix",
        "Cancel"
    )

    if confirm.Button ~= 1 then return 0, 0 end

    local success = 0
    local failed = 0

    for _, row in pairs(rows) do
        local ok = pcall(function()
            Sql.Execute("UPDATE scanpaths SET deviceid='"..newSerial.."' WHERE id="..row["Id"])
        end)

        if ok then success = success + 1 else failed = failed + 1 end
    end

    return success, failed
end

--------------------------------------------------
-- TITLE UPDATES (SMART + VERSION)
--------------------------------------------------
function fixTitleUpdates(newSerial)

    local rows = {}
    local dialog = ""

    for _, row in pairs(Sql.ExecuteFetchRows(
    "SELECT id, titleid, mediaid, baseversion, version, hash, filename, displayname, livedeviceid " ..
    "FROM titleupdates ORDER BY displayname ASC"
) or {}) do
        if row["LiveDeviceId"] ~= newSerial then
            table.insert(rows, row)

            dialog = dialog ..
                row["DisplayName"] ..
                " (v"..tostring(row["Version"])..") (" ..
                string.sub(row["LiveDeviceId"],1,6) ..
                " → " ..
                string.sub(newSerial,1,6) ..
                ")\n"
        end
    end

    if #rows == 0 then
        Script.ShowMessageBox("Title Updates", "No Title Update needs to be changed.", "OK")
        return 0, 0, 0
    end

    local confirm = Script.ShowMessageBox(
        "Title Updates found",
        dialog,
        "Fix",
        "Skip"
    )

    if confirm.Button ~= 1 then return 0, 0, 0 end

    local success = 0
    local failed = 0
    local removed = 0

    for _, row in pairs(rows) do

        local exists = Sql.ExecuteFetchRows(
    "SELECT id FROM titleupdates " ..
    "WHERE filename='" .. row["FileName"] ..
    "' AND titleid='" .. row["TitleId"] ..
    "' AND mediaid='" .. row["MediaId"] ..
    "' AND baseversion='" .. row["BaseVersion"] ..
    "' AND version='" .. row["Version"] ..
    "' AND hash='" .. row["Hash"] ..
    "' AND livedeviceid='" .. newSerial ..
    "' AND id<>" .. row["Id"]
)

        if exists and #exists > 0 then
            -- Remove true duplicate already existing on the target device.
            local ok = pcall(function()
                Sql.Execute("DELETE FROM titleupdates WHERE id="..row["Id"])
            end)

            if ok then removed = removed + 1 else failed = failed + 1 end

        else
            -- update normally
            local ok = pcall(function()
                Sql.Execute("UPDATE titleupdates SET livedeviceid='"..newSerial.."' WHERE id="..row["Id"])
            end)

            if ok then success = success + 1 else failed = failed + 1 end
        end
    end

    return success, failed, removed
end

--------------------------------------------------
-- MAIN
--------------------------------------------------
function main()

    --------------------------------------------------
    -- BACKUP WARNING
    --------------------------------------------------
    local backupWarning = Script.ShowMessageBox(
        "Important Warning",
        "Before continuing, it is highly recommended to back up the Aurora database.\n\n" ..
        "Default location:\n" ..
        "Data\\Databases\\content.db\n" ..
        "or\n" ..
        "User\\Data\\Databases\\content.db\n\n" ..
        "Do you want to continue anyway?",
        "Continue",
        "Cancel"
    )

    if backupWarning.Button ~= 1 then return end

    local drive = selectDrive()
    if not drive then return end

    local confirm = Script.ShowMessageBox(
        "Confirm",
        "Device:\n\n" ..
        drive.mount ..
        "\nSerial: " .. string.sub(drive.serial,1,16) ..
        "\n\nContinue?",
        "Yes",
        "Cancel"
    )

    if confirm.Button ~= 1 then return end

    local skipScan = askSkipScanpaths()

    local scanOK, scanFail = 0, 0
    if not skipScan then
        scanOK, scanFail = fixScanpaths(drive.serial)
    end

    local tuOK, tuFail, tuRemoved = fixTitleUpdates(drive.serial)

    local msg =
        "Scanpaths fixed: "..scanOK..
        "\nScanpath failures: "..scanFail..
        "\n\nTUs fixed: "..tuOK..
        "\nTUs removed (true duplicates): "..tuRemoved..
        "\nTU failures: "..tuFail..
        "\n\nRestart Aurora to apply the changes."

    local confirm = Script.ShowMessageBox(
        "Completed",
        msg,
        "Restart",
        "Later"
    )

    if confirm.Button == 1 then
        Aurora.Restart()
    end
end