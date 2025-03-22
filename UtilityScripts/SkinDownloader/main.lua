scriptTitle = "Skin Downloader"
scriptAuthor = "Dan Martí"
scriptVersion = 2;
scriptDescription =
    "Download skins, backgrounds and coverflows for Aurora\nfb.com/Danotopia\nhttp://aurorascripts.lmhsoluciones.com/"
scriptIcon = "icon.png"
scriptPermissions = {"http", "filesystem", "settings"}
require("AuroraUI")
require("MenuSystem")
json = require("json")
gizmo = require("Gizmo")
local a = "http://aurorascripts.lmhsoluciones.com/"
local b;
paths = {
    ['backgrounds'] = "Game:\\User\\Backgrounds\\",
    ['coverflows'] = "Game:\\Media\\Layouts\\",
    ['skins'] = "Game:\\Skins\\"
}
extension = {
    ['backgrounds'] = ".jpg",
    ['coverflows'] = ".cfljson",
    ['skins'] = ".xzp"
}
function main()
    if Aurora.HasInternetConnection() ~= true then
        Script.ShowMessageBox("ERROR",
            "ERROR: This script requires an active internet connection to work...\n\nPlease make sure you have internet to your console before running the script",
            "OK")
        return
    end
    print("-- " .. scriptTitle .. " Started...")
    local c = CheckUpdate()
    if c then
        goto d
    end
    Script.CreateDirectory("Screenshots")
    if MakeMainMenu() then
        DoShowMenu()
    end
    ::d::
    Script.RefreshListOnExit(c)
    print("-- " .. scriptTitle .. " Ended...")
end
function getcontent()
    Script.SetStatus("Downloading the content list...")
    Script.SetProgress(10)
    b = httpJson("list.php")
    if b == false then
        print("Error downloading list, exiting...")
        Script.ShowMessageBox("ERROR", "An error occurred while downloading the content list\n\nPlease try again later",
            "OK")
        return false
    else
        return true
    end
end
function MakeMainMenu()
    Menu.ResetMenu()
    Menu.SetTitle(scriptTitle)
    Menu.SetGoBackText("")
    Menu.AddMainMenuItem(Menu.MakeMenuItem("Backgrounds", "backgrounds"))
    Menu.AddMainMenuItem(Menu.MakeMenuItem("Coverflows", "coverflows"))
    Menu.AddMainMenuItem(Menu.MakeMenuItem("Skins", "skins"))
    Menu.AddMainMenuItem(Menu.MakeMenuItem("About the script", "about"))
    return true
end
function DoShowMenu(e)
    local f = {}
    local g = false;
    local h = {}
    if e == nil then
        getcontent()
        f, e, g, h = Menu.ShowMainMenu()
    else
        f, e, g, h = Menu.ShowMenu(e)
    end
    if not g then
        if f == "about" then
            Script.ShowMessageBox(scriptTitle .. " v" .. scriptVersion,
                "This script was made by Dan Martí, hosted by FeArCxDxGx and supported by the entire Aurora's community for uploading the content.\nThe script is nothing without you guys.\nThank you so much!\n\nFor more information visit aurorascripts.lmhsoluciones.com",
                "OK")
            DoShowMenu(e)
            return
        else
            if Menu.IsMainMenu(e) and e.SubMenu == nil then
                local i;
                i = paths[f]
                if next(b[f]) == nil then
                    Script.ShowMessageBox(scriptTitle, "There are no uploaded " .. f, "OK")
                    DoShowMenu()
                    return
                else
                    for j, k in pairs(b[f]) do
                        local l = k.autor;
                        local m = k.nombre;
                        local n = k.version;
                        local o = ""
                        if FileSystem.FileExists(i .. k.archivo) then
                            o = "√ "
                        else
                            o = ""
                        end
                        if n == "" then
                            Menu.AddSubMenuItem(h, Menu.MakeMenuItem(o .. m .. " by " .. l, k))
                        else
                            Menu.AddSubMenuItem(h, Menu.MakeMenuItem(o .. m .. " v" .. n .. " by " .. l, k))
                        end
                    end
                end
            end
        end
        if h.SubMenu ~= nil then
            DoShowMenu(h.SubMenu)
        elseif not Menu.IsMainMenu(e) then
            HandleSelection(f, e.Parent.Data, e)
        else
            Script.ShowMessageBox("ERROR", "An unknown error occurred!\n\nExiting...", "OK")
        end
    end
end
function httpJson(p)
    local q = Http.Get(a .. p)
    if q.Success then
        return json:decode(q.OutputData)
    else
        print(q)
        return false
    end
end
local function r(s, t)
    local u = 10 ^ (t or 0)
    return math.floor(s * u + 0.5) / u
end
function HandleSelection(v, w, e)
    local x = v.id;
    local y = v.hash;
    local m = v.nombre;
    local l = v.autor;
    local z = v.archivo;
    local n = v.version;
    local A = v.size;
    local B = "Screenshots\\" .. x .. "_" .. n .. ".jpg"
    if Script.FileExists(B) == false then
        Script.SetProgress(25)
        Script.SetStatus("Downloading screenshot...")
        local C = Http.Get(a .. "/" .. w .. "/" .. x .. ".jpg", B)
        if C.Success == true then
            print("image '" .. B .. "' download successfully")
        else
            FileSystem.DeleteFile(Script.GetBasePath() .. "Screenshots\\" .. x .. "_" .. n .. ".jpg")
            Script.ShowNotification("Screenshot download failed!")
            print("image '" .. B .. "' download failed")
        end
    end
    Script.SetStatus("Loading " .. w .. " info...")
    ::D::
    Script.SetProgress(100)
    local E = gizmo.run(v, w)
    if E.Result == "moreinfo" then
        if w == "backgrounds" then
            Script.ShowMessageBox("Background Information",
                "Name: " .. v.nombre .. "\nAuthor: " .. v.autor .. "\nFile Name: " .. v.archivo .. "\nFile Size: " ..
                    r(tonumber(v.size) / 1024 / 1024, 2) .. "Mb", "OK")
        elseif w == "coverflows" then
            Script.ShowMessageBox("Coverflow Information",
                "Name: " .. v.nombre .. "\nAuthor: " .. v.autor .. "\nVersion: " .. v.version .. "\nFile Name: " ..
                    v.archivo .. "\nFile Size: " .. r(tonumber(v.size) / 1024, 2) .. "Kb", "OK")
        else
            Script.ShowMessageBox("Skin Information",
                "Name: " .. v.nombre .. "\nAuthor: " .. v.autor .. "\nVersion: " .. v.version .. "\nFile Name: " ..
                    v.archivo .. "\nFile Size: " .. r(tonumber(v.size) / 1024 / 1024, 2) .. "Mb", "OK")
        end
        goto D
    end
    if E.Result == "download" then
        local i;
        i = paths[w]
        local F = w:sub(1, -2)
        Script.SetProgress(0)
        Script.SetStatus("Downloading " .. F .. " " .. m .. "...")
        if FileSystem.FileExists(i .. z) then
            Script.SetProgress(25)
            Script.SetStatus(z .. " exists! Checking hash...")
            local G = Aurora.Md5HashFile(i .. z)
            if G == y then
                if w == "skins" or w == "backgrounds" then
                    local f = Script.ShowMessageBox("", "The file is already in the " .. w ..
                        " folder, do you want to apply it?", "Yes", "No")
                    if f.Button == 1 then
                        if w == "backgrounds" then
                            settingapply("BackgroundFile", z)
                        elseif w == "skins" then
                            settingapply("Skin", z, true)
                        end
                        goto H
                    else
                        goto H
                    end
                else
                    local f = Script.ShowMessageBox("", "The file is already in the " .. w ..
                        " folder, do you want to download it again?", "Yes", "No")
                    if f.Button ~= 1 then
                        goto H
                    end
                end
            else
                local f = Script.ShowMessageBox("", "The " .. F .. " is already in the " .. w ..
                    " folder but it is another version, do you want to download it anyway?", "Yes", "No")
                if f.Button ~= 1 then
                    goto H
                end
            end
        end
        ::I::
        Script.CreateDirectory("Downloads")
        local J = "Downloads\\" .. z;
        local K = Http.Get(a .. w .. "/" .. x .. extension[w], J)
        if K == nil then
            print("Error Downloading: H: " .. a .. "; Type: " .. F .. "; ID: " .. x)
            Script.ShowMessageBox("Error", "There was an error trying to download the " .. F, "OK")
            return false
        end
        if K.Success == true then
            local G = Aurora.Md5HashFile(K.OutputPath)
            if G ~= y then
                Script.SetStatus("Download failed!")
                Script.SetProgress(0)
                print("MD5 failed: got(" .. G .. ") expected(" .. y .. ")")
                Script.ShowMessageBox("", "The " .. F ..
                    " cannot be downloaded (unmatching MD5 hash)\n see the FAQ on the website", "OK")
                goto H
            end
            Script.SetStatus("Downloaded! Copying...")
            Script.SetProgress(90)
            local L = FileSystem.MoveFile(K.OutputPath, i .. z, true)
            if L == false then
                print(z .. " copy failed")
                Script.ShowMessageBox("", "The " .. F .. " cannot be moved, move it manually to the " .. w .. " folder",
                    "OK")
            else
                print(z .. " copy successfully")
                if w == "skins" or w == "backgrounds" then
                    local f = Script.ShowMessageBox("", "The " .. F ..
                        " was successfully downloaded!\nDo you want to apply it?", "Yes", "No")
                    if f.Button == 1 then
                        if w == "backgrounds" then
                            settingapply("BackgroundFile", z)
                        elseif w == "skins" then
                            settingapply("Skin", z, true)
                        end
                        goto H
                    else
                        goto H
                    end
                else
                    askrestart("The " .. F .. " was successfully downloaded")
                end
            end
        else
            print(J .. " download failed")
            Script.ShowMessageBox("", "There was an error downloading the " .. F .. ", try again later", "OK")
        end
    end
    ::H::
    FileSystem.DeleteDirectory(Script.GetBasePath() .. "Downloads")
    Script.SetStatus("Loading menu...")
    DoShowMenu(e)
end
function askrestart(M)
    local f = Script.ShowMessageBox(scriptTitle, M .. ", you want to restart Aurora?", "Yes", "No")
    if f.Button == 1 then
        print("Restarting Aurora")
        Aurora.Restart()
    end
end
function settingapply(N, O, P)
    local Q;
    if P == true then
        Q = Settings.SetSystem(N, O)
    else
        Q = Settings.SetUser(N, O)
    end
    print(O .. " apply succesful")
    askrestart("Done!\n" .. O .. " has been applied")
    return true
end
function HandleZipInstall(v, i, R)
    local S = i;
    Script.SetStatus("Downloading Script...")
    Script.SetProgress(0)
    local T = "tmp.7z"
    local q = Http.Get(v.zipurl, T)
    if q.Success then
        Script.SetStatus("Extracting Script...")
        Script.SetProgress(25)
        local U = ZipFile.OpenFile(T)
        if U == nil then
            Script.ShowMessageBox("ERROR", "Extraction failed!", "OK")
            return false
        end
        local L = U.Extract(U, "tmp\\")
        FileSystem.DeleteFile(q.OutputPath)
        if L == false then
            Script.ShowMessageBox("ERROR", "Extraction failed!", "OK")
        else
            Script.SetStatus("Installing Script...")
            Script.SetProgress(75)
            L = FileSystem.MoveDirectory(S .. "tmp\\", S, true)
            Script.SetStatus("Done! Returning to menu...")
            Script.SetProgress(100)
            if L == true then
                return true
            else
                Script.ShowMessageBox("ERROR", "Installation failed!", "OK")
            end
        end
    else
        Script.ShowMessageBox("ERROR", "Download failed\n\nPlease try again later...", "OK")
    end
    return false
end
function CheckUpdate()
    local p = a .. "Update.ini"
    Script.SetStatus("Downloading Update information...")
    Script.SetProgress(0)
    local q = Http.Get(p)
    if q == nil then
        Script.ShowNotification("Error connecting to the server...")
        return false
    end
    if q.Success then
        Script.SetStatus("Parsing Update information...")
        Script.SetProgress(50)
        local V = IniFile.LoadString(q.OutputData)
        local W = V:GetSection("SkinDownloader")
        if tonumber(W.scriptVersion) > tonumber(scriptVersion) then
            local f;
            if W.required == "1" then
                f = Script.ShowMessageBox("Skin Downloader update available",
                    "An update of Skin Downloader is required (v" .. W.scriptVersion ..
                        ").\nDo you want to download it?", "Yes", "No")
                if f.Button == 2 then
                    refreshRequired = true;
                    return refreshRequired
                end
            else
                f = Script.ShowMessageBox("Skin Downloader update available",
                    "A new version of Skin Downloader is available (v" .. W.scriptVersion ..
                        "), do you want to download it?", "Yes", "No")
            end
            if f.Button == 1 then
                refreshRequired = HandleZipInstall(W, Script.GetBasePath(), "")
                return refreshRequired
            end
        end
        Script.SetStatus("Update check finished...")
        Script.SetProgress(100)
    else
        Script.ShowNotification("Error downloading update information...")
    end
    return false
end
