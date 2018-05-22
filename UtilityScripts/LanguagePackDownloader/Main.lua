scriptTitle = "Language Pack Downloader"
scriptAuthor = "Swizzy"
scriptVersion = 2
scriptDescription = "Swizzy's Language Pack Downloader, downloads Language Packs compatible with your version of Aurora"
scriptPermissions = { "http", "filesystem" }

require("MenuSystem");

listurl="http://lang.gxarena.com/list.ini"

-- Main entry point to script
function main()
	if Aurora.HasInternetConnection() ~= true then
		Script.ShowMessageBox("ERROR", "ERROR: This script requires an active internet connection to work...\n\nPlease make sure you have internet to your console before running the script", "OK");
		return;
	end
	print("-- " .. scriptTitle .. " Started...");
	if init() then
		MakeMainMenu();
		DoShowMenu(); -- This is basically where all the magic starts
		FileSystem.DeleteDirectory(absoluteDownloadsPath);
	else 
		Script.ShowMessageBox("ERROR", "ERROR: There was an error while downloading/processing the language pack list...", "OK");
	end
	print("-- " .. scriptTitle .. " Ended...");
end

function init()
	ret = Http.Get(listurl);	
	if ret.Success then
		ini = IniFile.LoadString(ret.OutputData);
		ver = Aurora.GetDashVersion();
		ver = ver.Major .. "." .. ver.Minor;
		basePath = ini:ReadValue(ver, "path", "");
		url = ini:ReadValue(ver, "url", "");
		if basePath == "" or url == "" then
			return false; -- It's not valid
		end
		ret = Http.Get(url);
		if ret.Success then
			ini = IniFile.LoadString(ret.OutputData);
			downloadsPath = "Downloads\\";
			absoluteDownloadsPath = Script.GetBasePath() .. downloadsPath;
			FileSystem.DeleteDirectory(absoluteDownloadsPath);
			return true;
		end
		
	end
	return false;
end

function MakeMainMenu()
	Menu.SetTitle(scriptTitle);
	Menu.SetGoBackText("");
	for _, v in pairs(ini:GetAllSections()) do
		local title = ini:ReadValue(v, "lang", "") .. " by ".. ini:ReadValue(v, "translator", "");
		if title ~= "" then
			Menu.AddMainMenuItem(Menu.MakeMenuItem(title, ini:GetSection(v)))
		end
	end
end

function DoShowMenu()
	local ret = {}
	local canceled = false;
	local menuItem = {}
	ret, _, canceled = Menu.ShowMainMenu();
	if not canceled then
		HandleSelection(ret);
	end
end

function HandleSelection(selection)
	local info = "";
	info = info .. "Language: "..selection.lang.."\n";
	info = info .. "Translator: "..selection.translator.."\n";
	info = info .. "\n\n\nDo you want to install this Language Pack?";
	local ret = Script.ShowMessageBox("", info, "Yes", "No");
	if ret.Button == 1 then
		HandleInstall(selection, basePath)
	end
	DoShowMenu();
end

function HandleInstall(selection, path)
	local installPath = path..selection.name;
	local filename = selection.name;
	if FileSystem.FileExists(installPath) then
		if  not HandleAlreadyExists(filename) then
			while FileSystem.FileExists(installPath) do
				installPath, filename, canceled = GetNewName(filename, path, "Select new filename:", ".xzp");
				if canceled then
					return false; -- We're not going to continue trying this
				end
			end
		end
	end
	Script.SetStatus("Downloading Language Pack...");
	Script.SetProgress(0);
	local http = Http.Get(selection.url, downloadsPath..selection.name);
	if http.Success then
		Script.SetStatus("Installing Language Pack...");
		Script.SetProgress(50);
		local result = FileSystem.MoveFile(http.OutputPath, installPath, true);
		Script.SetStatus("Done! Returning to menu...");
		Script.SetProgress(100);
		if result == true then
			return true;
		else
			Script.ShowMessageBox("ERROR", "Installation failed!", "OK");
		end
	else
		Script.ShowMessageBox("ERROR", "Download failed\n\nPlease try again later...", "OK");
	end
	return false;
end


function HandleAlreadyExists(name)
	local msg = "There is a Language Pack already installed with the name:\n"..name.."\n\nDo you want to overwrite/replace it?";
	local ret = Script.ShowMessageBox("Language Pack Already Exists", msg, "No", "Yes");
	if ret.Canceled or ret.Button ~= 2 then
		return false;
	end
	return true;
end

function GetNewName(currentName, path, prompt, extension)
	local extlen = 0;
	if extension ~= nil then
		extlen = 0 - string.len(extension);
		if string.lower(string.sub(currentName, extlen)) == extension then
			currentName = string.sub(currentName, 0, extlen - 1);
		end
	end
	local ret = Script.ShowKeyboard(scriptTitle, prompt, currentName, 0);
	if ret.Canceled == false then
		if extension ~= nil then
			if string.lower(string.sub(ret.Buffer, extlen)) ~= extension then
				ret.Buffer = ret.Buffer..extension;
			end
		end
		return path..ret.Buffer, ret.Buffer, ret.Canceled;
	end
	return path..currentName, currentName, ret.Canceled;
end