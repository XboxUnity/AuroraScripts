scriptTitle = "Aurora Drive Fixer Smart"
scriptAuthor = "Eduardo Henrique/Canal Edu Dicas e Gameplay"
scriptVersion = 1.0
scriptDescription = "Corrige scanpaths e Title Updates após clonagem de drive, com tratamento inteligente e seguro de duplicatas."
scriptIcon = "icon.png"
scriptPermissions = { "filesystem", "sql" }

ExitTriggered = false

--------------------------------------------------
-- SELECIONAR DRIVE (SERIAL)
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
        "Selecione o drive onde estão os jogos:",
        "Nenhum dispositivo encontrado.",
        dialog
    )

    if result.Canceled then
        ExitTriggered = true
        return nil
    end

    return drives[result.Selected.Key]
end

--------------------------------------------------
-- PERGUNTAR SE QUER PULAR SCANPATHS
--------------------------------------------------
function askSkipScanpaths()

    local confirm = Script.ShowMessageBox(
        "Scanpaths",
        "Deseja corrigir Scanpaths também?\n\n(Se não, apenas Title Updates serão corrigidos)",
        "Sim",
        "Apenas TUs"
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
        Script.ShowMessageBox("Scanpaths", "Nenhum scanpath precisa ser alterado.", "OK")
        return 0, 0
    end

    local confirm = Script.ShowMessageBox(
        "Scanpaths encontrados",
        dialog,
        "Corrigir",
        "Cancelar"
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
-- TITLE UPDATES (INTELIGENTE + VERSION)
--------------------------------------------------
function fixTitleUpdates(newSerial)

    local rows = {}
    local dialog = ""

    for _, row in pairs(Sql.ExecuteFetchRows("SELECT id, titleid, filename, version, displayname, livedeviceid FROM titleupdates ORDER BY displayname ASC") or {}) do
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
        Script.ShowMessageBox("Title Updates", "Nenhum TU precisa ser alterado.", "OK")
        return 0, 0, 0
    end

    local confirm = Script.ShowMessageBox(
        "Title Updates encontrados",
        dialog,
        "Corrigir",
        "Pular"
    )

    if confirm.Button ~= 1 then return 0, 0, 0 end

    local success = 0
    local failed = 0
    local removed = 0

    for _, row in pairs(rows) do

        local exists = Sql.ExecuteFetchRows(
            "SELECT id FROM titleupdates WHERE filename='"..row["FileName"]..
            "' AND titleid='"..row["TitleId"]..
            "' AND version='"..row["Version"]..
            "' AND livedeviceid='"..newSerial.."'"
        )

        if exists and #exists > 0 then
            -- remover duplicado REAL (mesma versão)
            local ok = pcall(function()
                Sql.Execute("DELETE FROM titleupdates WHERE id="..row["Id"])
            end)

            if ok then removed = removed + 1 else failed = failed + 1 end

        else
            -- atualizar normalmente
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
    -- AVISO DE BACKUP
    --------------------------------------------------
    local backupWarning = Script.ShowMessageBox(
        "Aviso Importante",
        "Antes de continuar, é altamente recomendado fazer um backup do banco de dados da Aurora.\n\n" ..
        "Local padrão:\n" ..
        "Data\\Databases\\content.db\n" ..
        "ou\n" ..
        "User\\Data\\Databases\\content.db\n\n" ..
        "Deseja continuar mesmo assim?",
        "Continuar",
        "Cancelar"
    )

    if backupWarning.Button ~= 1 then return end

    local drive = selectDrive()
    if not drive then return end

    local confirm = Script.ShowMessageBox(
        "Confirmar",
        "Dispositivo:\n\n" ..
        drive.mount ..
        "\nSerial: " .. string.sub(drive.serial,1,16) ..
        "\n\nContinuar?",
        "Sim",
        "Cancelar"
    )

    if confirm.Button ~= 1 then return end

    local skipScan = askSkipScanpaths()

    local scanOK, scanFail = 0, 0
    if not skipScan then
        scanOK, scanFail = fixScanpaths(drive.serial)
    end

    local tuOK, tuFail, tuRemoved = fixTitleUpdates(drive.serial)

    local msg =
        "Scanpaths corrigidos: "..scanOK..
        "\nFalhas scanpaths: "..scanFail..
        "\n\nTUs corrigidos: "..tuOK..
        "\nTUs removidos (duplicados reais): "..tuRemoved..
        "\nFalhas TUs: "..tuFail..
        "\n\nReinicie a Aurora para aplicar as mudanças."

    local confirm = Script.ShowMessageBox(
        "Concluído",
        msg,
        "Reiniciar",
        "Depois"
    )

    if confirm.Button == 1 then
        Aurora.Restart()
    end
end