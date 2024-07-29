scriptTitle = "Homebrew Store"
scriptAuthor = "Derf / Cheato"
scriptVersion = 1.0
scriptDescription = "Download homebrew from ConsoleMods.org and other repos!"
scriptIcon = "icon.png"
scriptPermissions = { "http", "sql", "filesystem" }
--Built from AuroraRepo. Please be gentle :)
require("MenuSystem");

local reloadRequired = false;
downloadsPath = "Downloads\\";
absoluteDownloadsPath = Script.GetBasePath() .. downloadsPath;

-- Main entry point to script
function main()
	if Aurora.HasInternetConnection() ~= true then
		Script.ShowMessageBox("ERROR", "ERROR: This script requires an active internet connection to work...\n\nPlease make sure you have internet to your console before running the script", "OK");
		return;
	end
	print("-- " .. scriptTitle .. " Started...");
	
	if init() == false then
		goto scriptend;
	end

	MakeMainMenu();
	DoShowMenu();

	if reloadRequired then
		local ret = Script.ShowMessageBox("Aurora Reload Required", "A Reload is required for your changes to take effect\n\nDo you want to reload Aurora now?", "Yes", "No");
		if ret.Button == 1 then
			Aurora.Restart();
		end
	end
	
	::mainend::
	FileSystem.DeleteDirectory(absoluteDownloadsPath);
	print("-- " .. scriptTitle .. " Ended...");
	::scriptend::
end

function init()
	-- Clear out unfinished downloads
	FileSystem.DeleteDirectory(absoluteDownloadsPath);

	-- Update saved repos
	Script.SetStatus("Updating repos...");
	Script.SetProgress(5);
	local updatingIndex = 0;
	local repos = FileSystem.GetFiles( Script.GetBasePath() .. "Repos\\*" );
	for i, repo in pairs(repos) do
		local repoDisplayName = repo.Name:gsub("%.ini$", "");
		Script.SetStatus("Updating " .. repoDisplayName .. "...");
		updatingIndex = updatingIndex + 1;

		if updatingIndex < 6 then
			Script.SetProgress(5+(15*updatingIndex));
		end
		
		local remoteRepoIniToUpdate = IniFile.LoadFile( "Repos\\" .. repo.Name);
		local remoteRepoIniSection = remoteRepoIniToUpdate:GetSection("update");

		if remoteRepoIniSection ~= nil then
			local repourl = remoteRepoIniSection.repourl;
			if repourl ~= nil then
				http = Http.Get(repourl, "\\Repos\\" .. repo.Name );
				if not http.Success then
					Script.ShowMessageBox("ERROR","Could not connect to " .. repoDisplayName,"OK");
				end
			end
		end
	end
end

function MakeMainMenu()
	Menu.SetTitle(scriptTitle);
	Menu.SetGoBackText("");

	local repos = FileSystem.GetFiles( Script.GetBasePath() .. "Repos\\*" );
	for i, repo in pairs(repos) do
		remoteRepoIni = IniFile.LoadFile( "Repos\\" .. repo.Name);
		remoteRepoIniSections = remoteRepoIni:GetAllSections();

		if remoteRepoIniSections ~= nil then
			for _, v in pairs(remoteRepoIniSections) do
				local title = remoteRepoIni:ReadValue(v, "name", "");
				if title ~= "" then
					Menu.AddMainMenuItem(Menu.MakeMenuItem(title, remoteRepoIni:GetSection(v)));
				end
			end
		end
	end

	Menu.AddMainMenuItem(Menu.MakeMenuItem("<enter URL>", { ["name"] = 'test',["iniurl"] = 'PROMPT',} ));
end

function DoShowMenu(menu)
	local ret = {}
	local canceled = false;
	local menuItem = {}

	if menu == nil then
		ret, menu, canceled, menuItem = Menu.ShowMainMenu();
	else
		ret, menu, canceled, menuItem = Menu.ShowMenu(menu);
	end

	if not canceled then
		if Menu.IsMainMenu(menu) and menu.SubMenu == nil then
			Script.SetStatus("Fetching listings...");
			local http, iniurl;
			Script.SetProgress(0);

			if (ret.iniurl == "PROMPT") then
				-- Prompt user for URL to .ini file
				local keyboardData = Script.ShowKeyboard( "Aurora Keyboard", "Enter the full URL to a valid .ini file", "https://", 64 );
				if keyboardData.Canceled == false then 
					iniurl = keyboardData.Buffer;
				else
					return;
				end

				iniRepoPath = Script.GetBasePath() .. "Repos\\";
				FileSystem.CreateDirectory( iniRepoPath );
				local newRepoName = string.match(iniurl,"^https?://([^/]+)");
				http = Http.Get(iniurl, "\\Repos\\" .. newRepoName .. ".ini" );
				Script.ShowNotification(newRepoName .. " repo installed!");
				return
			else
				-- Load .ini from Repo .ini entry
				http = Http.Get(ret.iniurl);
			end

			if http.Success then
				Script.SetStatus("Processing listings...");
				Script.SetProgress(50);
				local ini = IniFile.LoadString(http.OutputData);
				
				for _, v in pairs(ini:GetAllSections()) do
					local title =  ini:ReadValue(v, "itemTitle", "");
					local ver =    ini:ReadValue(v, "itemVersion", "");
					local author = ini:ReadValue(v, "itemAuthor", "");

					if (title ~= "" and ver ~= "" and author ~= "") then
						Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem(title .. " (v" .. ver .. ")", ini:GetSection(v)));
					elseif (title ~= "") then
						Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem(title, ini:GetSection(v)));
					end
				end
			else
				Script.ShowMessageBox("ERROR", "An error occurred while downloading store data...\n\nPlease try again later", "OK");
				DoShowMenu(menu);
				return;
			end
		end

		if menuItem.SubMenu ~= nil then
			-- Open submenu
			DoShowMenu(menuItem.SubMenu);
		elseif not Menu.IsMainMenu(menu) then
			-- Content item selected
			HandleSelection(ret, menu.Parent.Data, menu);
		else
			Script.ShowMessageBox("ERROR", "An unknown error occurred!\n\nExiting...", "OK");
		end
	end
end

function HandleSelection(selection, repo, menu)
	local info = "";
	info = info .. "Name: " .. selection.itemTitle .. "\n";
	if selection.itemDescription ~= nil and selection.itemDescription ~= "" then
		info = info .. "Version: " .. selection.itemVersion .. "\n";
	else 
		info = info .. "Version: " .. "Unknown\n";
	end

	if selection.itemAuthor ~= nil and selection.itemAuthor ~= "" then
		info = info .. "Author: " .. selection.itemAuthor .. "\n";
	else
		info = info .. "Author: N/A\n";
	end

	if selection.itemDescription ~= nil and selection.itemDescription ~= "" then
		info = info .. "Description:\n" .. string.gsub(selection.itemDescription, "\\n", "\n") .. "\n\n";
	else
		info = info .. "Description: N/A";
	end

	local destinationPath = GetDestinationPath(selection, repo.type);
	if destinationPath ~= nil and destinationPath ~= "" then
		info = info .. "Installation Path:\n" .. destinationPath .. "\n";
	else
		return nil;
	end

	info = info .. "\n\n\nDo you want to install this ".. repo.type .."?";
	local ret = Script.ShowMessageBox("", info, "Yes", "No");
	if ret.Button == 1 then
		if HandleInstallation(selection, destinationPath, repo.type) then
			if repo.reload == "true" then
				reloadRequired = true;
			end
		end
	end
	DoShowMenu(menu);
end

function GetDirectoryForScanPath(pathid, deviceid)
	local mountpoint = nil;
	if deviceid ~= nil then
		for _, v in pairs(Sql.ExecuteFetchRows("SELECT MountPoint FROM MountedDevices WHERE DeviceId == \"" .. deviceid .. "\"")) do
			mountpoint = v.MountPoint;
			break;
		end
	end
	return mountpoint;
end

function GetScanPath(type)
	for _, v in pairs(Sql.ExecuteFetchRows("SELECT Id,Path,DeviceId,ScriptData FROM ScanPaths")) do
		local mountpoint = GetDirectoryForScanPath(v.Id, v.DeviceId);
		if mountpoint ~= nil then
			if type == "App" and v.ScriptData == "Applications" then
				return mountpoint .. v.Path .. "\\";
			elseif type == "Homebrew" and v.ScriptData == "Homebrew" then
				return mountpoint .. v.Path .. "\\";
			elseif type == "Emulator" and v.ScriptData == "Emulators" then
				return mountpoint .. v.Path .. "\\";
			end
		end
	end
end

function GetDestinationPath(selection, type)
	-- If ScanPaths not set in Aurora settings, then:
	-- App       - Installs to /Apps/
	-- Games     - Installs to /Games/
	-- Emulator  - Installs to /Emulators/
	-- Other     - Full path specified in .ini
	-----------------------------------------------------
	-- Official content - "Hdd1:\\Content\\0000000000000000\\";
	
	local applicationsDirectory = GetScanPath("App");
	local homebrewDirectory = GetScanPath("Homebrew");
	local emulatorsDirectory = GetScanPath("Emulator");

	if type == "App" then
		if applicationsDirectory ~= nil then
			return applicationsDirectory .. selection.path;
		else
			return "Hdd1:\\Apps\\" .. selection.path;
		end
	elseif type == "Game" then
		return "Hdd1:\\Games\\" .. selection.path;
	elseif type == "Emulator" then
		if emulatorsDirectory ~= nil then
			return emulatorsDirectory .. selection.path;
		else
			return "Hdd1:\\Emulators\\" .. selection.path;
		end
	elseif type == "Homebrew" then
		if homebrewDirectory ~= nil then
			return homebrewDirectory .. selection.path;
		else
			return "Hdd1:\\Homebrew\\" .. selection.path;
		end
	else 
		return selection.path;
	end
end

function HandleInstallation(selection, destinationPath, type)
	if string.match(selection.path, "Usb0:") then
		if not FileSystem.FileExists("Usb0:\\") then
			Script.ShowMessageBox("ERROR","This download requires a USB flash drive. Please plug one in and retry.","OK");
			return nil;
		end
	end

	if string.match(selection.dataurl, ".7z") then
		return HandleZipInstall(selection, destinationPath, type, true);
	elseif selection.dataurl ~= nil then
		return HandleFileInstall(selection, destinationPath, type, true);
	end
end

function HandleFileInstall(selection, destinationPath, type, checkExists)
	if checkExists == true then
		local filename = selection.path;
		if FileSystem.FileExists(destinationPath .. selection.path) then
			if not HandleAlreadyExists(type, filename) then
				return false; -- We're not going to continue trying this
			end
		end
	end
	Script.SetStatus("Downloading Content...");
	Script.SetProgress(10);
	local dlpath = downloadsPath .. "tmp.bin";
	local http = Http.Get(selection.dataurl, dlpath);
	Script.SetStatus("Moving Content...");
	Script.SetProgress(50);
	local successfulMove = FileSystem.MoveFile( absoluteDownloadsPath .. "tmp.bin", destinationPath .. selection.path, true);
	Script.SetProgress(75);
	FileSystem.DeleteDirectory(absoluteDownloadsPath);
	Script.ShowNotification(selection.itemTitle .. " Installed");
	return false;
end

function HandleZipInstall(selection, destinationPath, type, checkExists)
	if checkExists == true then
		local filename = selection.path;
		if FileSystem.FileExists(destinationPath .. selection.path) then
			if not HandleAlreadyExists(type, filename) then
				return false; -- We're not going to continue trying this
			end
		end
	end
	FileSystem.CreateDirectory( destinationPath .. string.match(selection.path, "^.+[\\]") );
	Script.SetStatus("Downloading Content...");
	Script.SetProgress(10);
	
	local updatingIndex = 0;
	local loadingProgress = 0;
	local installSuccess = false;
	
	-- Must be <350MB parts, otherwise the Aurora zip extractor breaks
	for key, dataurl in pairs(selection) do
		if string.match(key, "dataurl") then
			if updatingIndex < 8 then
				loadingProgress = 10+(10*updatingIndex);
				Script.SetProgress(loadingProgress);
			end
			updatingIndex = updatingIndex + 1;
			
			-- Download files
			local dlpath = downloadsPath .. "tmp.7z";
			local http = Http.Get(dataurl, dlpath);
			if http.Success then
				-- Unzip files
				Script.SetProgress(loadingProgress+5);
				local zip = ZipFile.OpenFile( dlpath );
				if zip == nil then
					Script.ShowMessageBox("ERROR", "Extraction failed!", "OK");
					return false;
				end
				Script.SetStatus("Decompressing Content...");
				local result = zip.Extract( zip, downloadsPath .. "tmp\\" );
				if result == false then
					Script.ShowMessageBox("ERROR", "Extraction failed!", "OK");
				else
					Script.SetProgress(loadingProgress+7);
					Script.SetStatus("Installing Content...");
					local successfulMove = FileSystem.MoveDirectory( absoluteDownloadsPath .. "tmp\\", string.match(destinationPath, "^.+[\\]"), true);
					Script.SetProgress(loadingProgress+9);

					if successfulMove == true then
						installSuccess = true;
					else
						Script.ShowMessageBox("ERROR", "Installation failed!", "OK");
						FileSystem.DeleteDirectory(absoluteDownloadsPath);
						return false;
					end
				end
			else
				Script.ShowMessageBox("ERROR", "Download failed\n\nPlease try again later...", "OK");
			end
		end
	end

	if installSuccess == true then
		Script.ShowNotification(selection.itemTitle .. " Installed");
	end

	FileSystem.DeleteDirectory(absoluteDownloadsPath);
	
	return true;
end

function HandleAlreadyExists(type, name)
	local msg = "There is a "..type.." already installed with the name:\n\n" .. name .. "\n\nDo you want to overwrite/replace it?";
	local ret = Script.ShowMessageBox("Item Already Exists", msg, "No", "Yes");
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

function HandleZipInstallUpdate(selection, path, type, checkExists)
	local installPath = path;
	if checkExists == true then
		installPath = installPath .. selection.path;
		local filename = selection.path;
		if FileSystem.FileExists(installPath) then
			if  not HandleAlreadyExists(type, filename) then
				while FileSystem.FileExists(installPath) do
					installPath, filename, canceled = GetNewName(filename, path, "Select new folder name:");
					if canceled then
						return false; -- We're not going to continue trying this
					end
				end
			end
		end
	end
	Script.SetStatus("Downloading Script...");
	Script.SetProgress(0);
	local dlpath = downloadsPath.."tmp.7z";
	local http = Http.Get(selection.dataurl, dlpath);
	if http.Success then
		Script.SetStatus("Extracting Script...");
		Script.SetProgress(25);
		local zip = ZipFile.OpenFile(dlpath);
		if zip == nil then
			Script.ShowMessageBox("ERROR", "Extraction failed!", "OK");
			return false;
		end
		local result = zip.Extract(zip, downloadsPath.."tmp\\");
		FileSystem.DeleteFile(http.OutputPath);
		if result == false then
			Script.ShowMessageBox("ERROR", "Extraction failed!", "OK");
		else
			Script.SetStatus("Installing Script...");
			Script.SetProgress(75);
			result = FileSystem.MoveDirectory(absoluteDownloadsPath.."tmp\\", installPath, true);
			Script.SetStatus("Done! Returning to menu...");
			Script.SetProgress(100);
			if result == true then
				return true;
			else
				Script.ShowMessageBox("ERROR", "Installation failed!", "OK");
			end
		end
	else
		Script.ShowMessageBox("ERROR", "Download failed\n\nPlease try again later...", "OK");
	end
	return false;
end
