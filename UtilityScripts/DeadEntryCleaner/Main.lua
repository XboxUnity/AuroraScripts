scriptTitle = "Dead Entry Cleaner (BETA)"
scriptAuthor = "Eduardo Henrique/Canal Edu Dicas e Gameplay"
scriptVersion = "1.0"
scriptDescription = "Removes ghost entries from Aurora (ContentItems). Does not alter games, DLCs, or TUs. May require a re-scan."

scriptPermissions = { "filesystem", "sql" }
scriptIcon = "icon.png"

--------------------------------------------------
-- CONTADORES
--------------------------------------------------

local removedCount = 0
local failedCount = 0
local scannedCount = 0
local deadCount = 0

--------------------------------------------------
-- LOG SYSTEM (USANDO DRIVE SELECIONADO)
--------------------------------------------------

local LOG_PATH = nil
local LOG_FILE = nil

--------------------------------------------------
-- DATA/HORA SEGURA
--------------------------------------------------

function getSafeDateTime()

    local ok, result = pcall(function()
        return os.date("%d/%m/%Y %H:%M:%S")
    end)

    if ok and result then
        return result
    end

    return "DATA_INDISPONIVEL"
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
    if id == "00000000" then return false end
    return true
end

--------------------------------------------------
-- SELEÇÃO DE DRIVE (UX MELHORADA)
--------------------------------------------------

function selectDrive()

    local drives = {}
    local dialog = {}

    local list = FileSystem.GetDrives(false)

    for i, d in ipairs(list) do

        local mount = d["MountPoint"]
        local serial = d["Serial"] or "UNKNOWN"

        local label = ""

        if string.find(safeLower(mount), "hdd") then
            label = "HDD (Armazenamento Interno)"
        elseif string.find(safeLower(mount), "usb") then
            label = "USB (Dispositivo Externo)"
        else
            label = "Dispositivo de Armazenamento"
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
        "SELECIONE O ARMAZENAMENTO PARA LIMPEZA",
        "Nenhum dispositivo encontrado.",
        dialog
    )

    if result.Canceled then
        return nil
    end

    return drives[result.Selected.Key]
end

--------------------------------------------------
-- GOD CHECK SIMPLES
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
-- PROTEÇÃO AVANÇADA (ANTI REMOÇÃO ACIDENTAL)
--------------------------------------------------

function isProtectedEntry(item)

    local title = safeLower(item.TitleName or "")
    local directory = safeLower(item.Directory or "")
    local executable = safeLower(item.Executable or "")
    local contentType = tonumber(item.ContentType or 0)
    local titleId = tostring(item.TitleId or "")

    --------------------------------------------------
    -- DASHBOARDS / SISTEMA
    --------------------------------------------------

    if string.find(title, "aurora") then return true end
    if string.find(title, "xexmenu") then return true end
    if string.find(title, "dashlaunch") then return true end
    if string.find(title, "dash launch") then return true end
    if string.find(title, "freestyle") then return true end

    -- nomes curtos = exactMatch
    if exactMatch(title, "fsd") then return true end

    if string.find(title, "quickboot") then return true end
    if string.find(title, "xell") then return true end
    if string.find(title, "nand flasher") then return true end
    if string.find(title, "simple nand flasher") then return true end
    if string.find(title, "rawflash") then return true end
    if string.find(title, "xebuild") then return true end

    --------------------------------------------------
    -- UTILITÁRIOS IMPORTANTES
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
    -- EMULADORES IMPORTANTES
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
    -- SERVIÇOS / REDE / PLUGINS
    --------------------------------------------------

    -- nomes curtos/genéricos = exactMatch
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
    -- PROTEÇÃO POR DIRECTORY (MUITO IMPORTANTE)
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
    -- PROTEÇÃO POR EXECUTABLE
    --------------------------------------------------

    if string.find(executable, "aurora") then return true end
    if string.find(executable, "xexmenu") then return true end
    if string.find(executable, "freestyle") then return true end
    if string.find(executable, "dashlaunch") then return true end
    if string.find(executable, "fbanext") then return true end
    if string.find(executable, "retroarch") then return true end

    --------------------------------------------------
    -- CONTENT TYPES CRÍTICOS
    --------------------------------------------------

    -- XeXMenu LIVE
    if contentType == 524288 then return true end

    -- Installed Xbox Classic
    if contentType == 20480 then return true end

    --------------------------------------------------
    -- TITLEIDS ESPECIAIS
    --------------------------------------------------

    if titleId == "-1059153511" then return true end -- QuickBoot
    if titleId == "C0DE9999" then return true end

    --------------------------------------------------
    -- SEGURANÇA EXTRA
    --------------------------------------------------

    if title == "" and directory == "" then
        return true
    end

    return false
end

--------------------------------------------------
-- DETECÇÃO SEGURA
--------------------------------------------------

function isDeadEntry(item, selectedMount)

    local directory = normalizePath(item.Directory or "")
    local executable = normalizePath(item.Executable or "")
    local contentType = tonumber(item.ContentType or 0)
    local titleId = tostring(item.TitleId or "")

    --------------------------------------------------
    -- DIRECTORY VAZIO
    --------------------------------------------------

    if directory == "" then
    return true, "DIRECTORY_VAZIO"
end

    --------------------------------------------------
    -- PROTEGIDO
    --------------------------------------------------

    if isProtectedEntry(item) then
        return false, "ENTRADA_PROTEGIDA"
    end

--------------------------------------------------
-- VERIFICA SE A PASTA NÃO EXISTE (ESSENCIAL)
--------------------------------------------------

if not dirExists(directory) then
    return true, "DIRETORIO_NAO_EXISTE"
end

    --------------------------------------------------
    -- MULTI DISC
    --------------------------------------------------

    if tonumber(item.DiscsInSet or 1) > 1 then
        return false, "MULTI_DISC_PROTEGIDO"
    end

    --------------------------------------------------
    -- TITLEID INVÁLIDO
    --------------------------------------------------

    if not isValidTitleId(titleId) then
        return false, "TITLEID_INVALIDO"
    end

    --------------------------------------------------
    -- XEX CHECK
    --------------------------------------------------

    if executable ~= "" and string.sub(safeLower(executable), -4) == ".xex" then

        if fileExists(directory .. "\\" .. executable) then
            return false, "XEX_EXISTE"
        end

        if fileExists(directory .. "\\default.xex") then
            return false, "DEFAULT_XEX_EXISTE"
        end

        if getFileCount(directory) > 0 then
            return false, "DIRETORIO_COM_ARQUIVOS"
        end

        return true, "XEX_INEXISTENTE"
    end

    --------------------------------------------------
    -- GOD CHECK
    --------------------------------------------------

    if contentType == 28672 then

        if isValidGOD(directory) then
            return false, "GOD_VALIDO"
        end

        return true, "GOD_INVALIDO"
    end

    --------------------------------------------------
    -- FALLBACK
    --------------------------------------------------

    if getFileCount(directory) > 0 then
        return false, "FALLBACK_DIRETORIO_COM_ARQUIVOS"
    end

    return true, "FALLBACK_ENTRADA_FANTASMA"
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
-- CHECKLIST UX REFORÇADO
--------------------------------------------------

local confirmStart = Script.ShowMessageBox(
    "CHECKLIST DE SEGURANÇA",
    "ANTES DE CONTINUAR:\n\n" ..

    "✔ Não apaga jogos do armazenamento\n" ..
    "✔ Não remove DLCs ou Title Updates\n" ..
    "✔ Apenas limpa entradas inválidas da Aurora\n\n" ..

    "✔ A biblioteca pode ser reconstruída após re-scan\n" ..
    "✔ Pode ser necessário re-escanear os caminhos após o uso\n\n" ..

    "✔ Backup do banco é recomendado (não obrigatório)\n" ..
    "Locais comuns do banco:\n" ..
    "Data\\Databases\\content.db\n" ..
    "User\\Data\\Databases\\content.db\n\n" ..

    "Deseja continuar?",
    "Continuar",
    "Cancelar"
)

if confirmStart.Button ~= 1 then return end

    --------------------------------------------------
    -- DRIVE
    --------------------------------------------------

    local drive = selectDrive()
    if not drive then return end

    local selectedMount = drive.mount

    local confirmDrive = Script.ShowMessageBox(
        "CONFIRMAÇÃO",
        "Armazenamento selecionado:\n" .. selectedMount .. "\n\n" ..
        "A limpeza será aplicada apenas na base de dados da Aurora.\nNenhum conteúdo físico será alterado.\nContinuar?",
        "Sim",
        "Cancelar"
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
    Script.ShowMessageBox("Erro", "Falha ao ler banco.", "OK")
    return
end

local deadItems = {}
local preview = ""

for i = 1, #rows do

    local item = rows[i]
    scannedCount = scannedCount + 1

    --------------------------------------------------
    -- Agora isDeadEntry deve retornar:
    -- return true/false, "MOTIVO"
    --------------------------------------------------

    local ok, dead, reason = pcall(function()
        return isDeadEntry(item, selectedMount)
    end)

    --------------------------------------------------
    -- Se houve erro interno durante análise
    --------------------------------------------------

    if not ok then

    else

        if dead then

            deadCount = deadCount + 1
            table.insert(deadItems, item)

            if deadCount <= 20 then
                preview = preview ..
                    "- " .. (item.TitleName or "???") ..
                    " | Motivo: " .. tostring(reason or "DESCONHECIDO") ..
                    "\n"
            end
        end
    end
end

if deadCount == 0 then

    Script.ShowMessageBox(
        "OK",
        "Nenhuma entrada fantasma encontrada.",
        "OK"
    )

    return
end

    --------------------------------------------------
    -- CONFIRMAÇÃO
    --------------------------------------------------

    local confirmRemove = Script.ShowMessageBox(
        "CONFIRMAR REMOÇÃO",
        "Encontrados: " .. deadCount .. "\n\n" ..
        preview .. "\n\nRemover do banco da Aurora?",
        "Remover",
        "Cancelar"
    )

    if confirmRemove.Button ~= 1 then return end

    --------------------------------------------------
    -- REMOÇÃO
    --------------------------------------------------

for i = 1, #deadItems do

    if removeContentItem(deadItems[i].Id) then

        removedCount = removedCount + 1

    else

        failedCount = failedCount + 1

    end
end

    --------------------------------------------------
    -- FINAL
    --------------------------------------------------

local restart = Script.ShowMessageBox(
    "FINALIZADO",
    "Escaneados: " .. scannedCount ..
    "\nRemovidos: " .. removedCount ..
    "\nFalhas: " .. failedCount ..
    "\n\nReiniciar Aurora para aplicar mudanças?",
    "Sim",
    "Não"
)

if restart.Button == 1 then
    Aurora.Restart()
else
    -- não faz nada
end
end