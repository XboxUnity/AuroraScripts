scriptTitle = "Homebrew Store"
scriptAuthor = "Derf / Cheato"
scriptVersion = 4.0
scriptDescription = "Download homebrew from ConsoleMods.org and other repos!"
scriptIcon = "icon.png"
scriptPermissions = { "http", "sql", "filesystem" }
--Built from AuroraRepo. Please be gentle :)
require("MenuSystem");

local reloadRequired = false;
downloadsPath = "Downloads\\";
gAbortedOperation = false;

-- Main entry point to script
function main()
	if Aurora.HasInternetConnection() ~= true then
		Script.ShowMessageBox("ERROR", "This script requires an active internet connection to work...\n\nPlease make sure you have internet to your console before running the script", "OK");
		return;
	end
	print("-- " .. scriptTitle .. " started...");
	
	if init() == false then
		goto scriptend;
	end

	MakeMainMenu();
	DoShowMenu();

	if reloadRequired and not gAbortedOperation then
		local ret = Script.ShowMessageBox("Aurora Reload Required", "A Reload is required for your changes to take effect\n\nDo you want to reload Aurora now?", "Yes", "No");
		if ret.Button == 1 then
			Aurora.Restart();
		end
	end
	
	::mainend::
	FileSystem.DeleteDirectory(absoluteDownloadsPath);
	print("-- " .. scriptTitle .. " ended...");
	::scriptend::
end

function init()
	-- Clear out unfinished downloads
	absoluteDownloadsPath = Script.GetBasePath() .. downloadsPath;
	FileSystem.DeleteDirectory(absoluteDownloadsPath);

	-- Load last selected storage device
	confPath = Script.GetBasePath() .. "homebrewstore.conf"
	storageDeviceFromConf = FileSystem.ReadFile(confPath);
	if (storageDeviceFromConf == nil) then
		FileSystem.WriteFile(confPath, "hdd1:\\");
		storageDeviceFromConf = FileSystem.ReadFile(confPath);
	end
	storageDevice = storageDeviceFromConf

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
	Menu.SetTitle(scriptTitle .. " (" .. storageDevice:gsub( "\\", "") .. ")");
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

	Menu.AddMainMenuItem(Menu.MakeMenuItem("Change Storage Device", { ["name"] = 'test2',["iniurl"] = 'CHANGE_STORAGE',} ));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("<enter URL>", { ["name"] = 'test',["iniurl"] = 'ENTER_URL',} ));
end

function DoShowMenu(menu)
	if gAbortedOperation then
		return;
	end

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

			if (ret.iniurl == "CHANGE_STORAGE") then
				-- Open menu to select storage device
				Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem("hdd1:", "hdd1:\\"));
				Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem("usb0:", "usb0:\\"));
				Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem("usb1:", "usb1:\\"));
				Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem("memunit0:", "memunit0:\\"));
				Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem("memunit1:", "memunit1:\\"));
			elseif (ret.iniurl == "ENTER_URL") then
				-- Prompt user for URL to .ini file
				local keyboardData = Script.ShowKeyboard( "Aurora Keyboard", "Enter the full URL to a valid .ini file", "https://", 0 );
				if keyboardData.Canceled == false then 
					iniurl = keyboardData.Buffer;
				else
					return;
				end

				iniRepoPath = Script.GetBasePath() .. "Repos\\";
				FileSystem.CreateDirectory( iniRepoPath );
				local newRepoName = string.match(iniurl,"^https?://([^/]+)");
				http = Http.Get(iniurl, "\\Repos\\" .. newRepoName .. ".ini" );
				if http.Success then
					Script.ShowNotification(newRepoName .. " repo installed!");
				else
					Script.ShowMessageBox("ERROR", "Failed to download .ini file:\n\n" .. iniurl, "OK");
				end

				return
			else
				-- Load .ini from Repo .ini entry
				http = Http.Get(ret.iniurl);
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

	if (selection.itemTitle == nil) then
		-- Change active storage device, save out to config file
		FileSystem.WriteFile(confPath, selection);
		storageDevice = FileSystem.ReadFile(confPath);
		Script.ShowNotification("Storage device set to " .. storageDevice:gsub( "\\", ""));
		return
	end

	if not FileSystem.FileExists(storageDevice) then
		Script.ShowMessageBox("ERROR","The selected storage device " .. storageDevice:gsub( "\\", "") .. " is not connected.","OK");
		return nil;
	end
	
	info = info .. "Name: " .. selection.itemTitle .. "\n";
	if selection.itemVersion ~= nil and selection.itemVersion ~= "" then
		info = info .. "Version: " .. selection.itemVersion .. "\n";
	end

	if selection.itemAuthor ~= nil and selection.itemAuthor ~= "" then
		info = info .. "Author: " .. selection.itemAuthor .. "\n";
	end

	if selection.itemSize ~= nil and selection.itemSize ~= "" then
		info = info .. "Size: " .. selection.itemSize .. "\n";
	end

	local destinationPath = GetDestinationPath(selection.path, repo.type);
	if destinationPath ~= nil and destinationPath ~= "" then
		info = info .. "Path: " .. destinationPath .. "\n";
	else
		return nil;
	end

	if selection.itemDescription ~= nil and selection.itemDescription ~= "" then
		info = info .. "Description:\n" .. string.gsub(selection.itemDescription, "\\n", "\n") .. "\n\n";
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

function GetDestinationPath(path, type)
	-- If ScanPaths not set in Aurora settings, then:
	-- App           - Installs to /Apps/
	-- Game          - Installs to /Games/
	-- Emulator      - Installs to /Emulators/
	-- PublicProfile - Installs to /Content/0000000000000000/
	-- Profile       - Installs to /Content/<profile ID>/ of signed-in user
	-- Other         - Full path specified in .ini
	
	local applicationsDirectory = GetScanPath("App");
	local gamesDirectory = GetScanPath("Game");
	local homebrewDirectory = GetScanPath("Homebrew");
	local emulatorsDirectory = GetScanPath("Emulator");

	if type == "App" then
		if applicationsDirectory ~= nil then
			return applicationsDirectory .. path;
		else
			return storageDevice .. "Apps\\" .. path;
		end
	elseif type == "Game" then
		if gamesDirectory ~= nil then
			return gamesDirectory .. path;
		else
			return storageDevice .. "Games\\" .. path;
		end
	elseif type == "Emulator" then
		if emulatorsDirectory ~= nil then
			return emulatorsDirectory .. path;
		else
			return storageDevice .. "Emulators\\" .. path;
		end
	elseif type == "Homebrew" then
		if homebrewDirectory ~= nil then
			return homebrewDirectory .. path;
		else
			return storageDevice .. "Homebrew\\" .. path;
		end
	elseif type == "PublicProfile" then
		return storageDevice .. "Content\\0000000000000000\\" .. path;
	elseif type == "Profile" then
		profileID = Profile.GetXUID(1);
		if profileID == "0" then
			Script.ShowMessageBox("ERROR", "You need to sign into a profile to download from this category.", "OK");
		else
			if string.len(profileID) == 16 then
				return storageDevice .. "Content\\" .. Profile.GetXUID(1) .. "\\" .. path;
			else
				-- When signed into Xbox Live, profile XUID changes to a 13 character string
				local profiles = Profile.EnumerateProfiles();
				for i, profile in pairs(profiles) do
					if profile.GamerTag == Profile.GetGamerTag(1) then
						return storageDevice .. "Content\\" .. profile.XUID .. "\\" .. path;
					end
				end
			end
		end
	else 
		return path;
	end
end

function HandleInstallation(selection, destinationPath, type)
	if string.match(selection.path, "Usb0:") then
		if not FileSystem.FileExists("Usb0:\\") then
			Script.ShowMessageBox("ERROR","This download requires a USB flash drive. Please plug one in and retry.","OK");
			return nil;
		end
	end

	local filename = selection.path;
	if FileSystem.FileExists(destinationPath) then
		if not HandleAlreadyExists(type, filename) then
			return false; -- We're not going to continue trying this
		end
	end
	
	FileSystem.CreateDirectory(destinationPath);
	--Script.SetStatus("Downloading content...");
	Script.SetProgress(10);

	local destinationFullPath = "";
	local partFileName = "";
	local updatingIndex = 0;
	local loadingProgress = 0;
	local installSuccess = false;
	gAbortedOperation = false;
	
	-- 7z files must be <350MB, otherwise the Aurora zip extractor breaks
	-- Other files can be seemingly unlimited size

	-- Add dataurl to table first
	local dataurls = {}
	for key in pairs(selection) do
		if string.match(key, "^dataurl$") then
			table.insert(dataurls, key);
			break;
		end
	end

	-- Add dataurlparts to table sequentially
	local total_parts = 1;
	local dataurl_index = 1;
	local match_found = true;
	while match_found do
		dataurl_index = dataurl_index + 1;
		match_found = false;
		for key in pairs(selection) do
			if string.match(key, "^dataurlpart" .. dataurl_index .. "$") then
				table.insert(dataurls, key);
				match_found = true;
				total_parts = total_parts + 1;
				break;
			end
		end
	end

	local dataurl;
	local current_part_index = 0;
	for key, dataurl_name in ipairs(dataurls) do
		current_part_index = current_part_index + 1;
		dataurl = selection[dataurl_name];
		-- If a file part, get part path
		if string.match(dataurl_name, "part") then
			local partname = string.sub(dataurl_name, 8, -1);
			destinationFullPath = "";
			for key2, partpath in pairs(selection) do
				if string.match(key2, partname .. "path") then
					destinationFullPath = GetDestinationPath(partpath, type);
				end
			end

			if destinationFullPath == "" then
				-- If no part path specified, default to path
				destinationFullPath = string.match(destinationPath, "^.+[\\]");
			end
		else
			-- This is dataurl and path
			destinationFullPath = string.match(destinationPath, "^.+[\\]");
		end
		FileSystem.CreateDirectory(destinationFullPath);

		if updatingIndex < 8 then
			loadingProgress = 10+(10*updatingIndex);
			Script.SetProgress(loadingProgress);
		end
		updatingIndex = updatingIndex + 1;
		
		-- Download files
		local dlpath = "";
		local successfulMove = false;
		if string.match(dataurl, ".7z") then
			dlpath = downloadsPath .. "tmp.7z";
		else
			dlpath = downloadsPath .. "tmp.bin";
		end

		Script.SetStatus("Downloading content (" .. current_part_index .. "/" .. total_parts .. ")...");
		local http = Http.GetEx(dataurl, HttpProgressRoutine, dlpath);
		if gAbortedOperation == true then 
			installSuccess = false;
			Script.ShowNotification("Download cancelled");
			Script.SetStatus("Exiting script...");
			FileSystem.DeleteDirectory(absoluteDownloadsPath);
		else
			if http.Success then
				Script.SetProgress(loadingProgress+5);

				if string.match(dataurl, ".7z") then
					-- Unzip files
					local zip = ZipFile.OpenFile( dlpath );
					if zip == nil then
						Script.ShowMessageBox("ERROR", "Could not open zip!", "OK");
						return false;
					end
					Script.SetStatus("Decompressing content (" .. current_part_index .. "/" .. total_parts .. ")...");
					local result = zip.Extract( zip, downloadsPath .. "tmp\\" );

					if result == false then
						Script.ShowMessageBox("ERROR", "Extraction failed!", "OK");
						FileSystem.DeleteDirectory(absoluteDownloadsPath);
						return false;
					else
						Script.SetProgress(loadingProgress+7);
						Script.SetStatus("Installing content (" .. current_part_index .. "/" .. total_parts .. ")...");
						successfulMove = FileSystem.MoveDirectory(absoluteDownloadsPath .. "tmp\\", string.match(destinationPath, "^.+[\\]"), true, CopyProgressRoutine);
						Script.SetProgress(loadingProgress+9);
					end
				else
					-- Copy single file to destination
					Script.SetProgress(loadingProgress+7);
					Script.SetStatus("Moving content (" .. current_part_index .. "/" .. total_parts .. ")...");
					partFileName = string.match(dataurl, "^.*/([^/]+)$");
					successfulMove = FileSystem.CopyFile(absoluteDownloadsPath .. "tmp.bin", destinationFullPath .. partFileName, true, CopyProgressRoutine);
					Script.SetProgress(loadingProgress+9);
				end

				if gAbortedOperation == true then
					Script.ShowNotification("Operation aborted!");
					Script.SetStatus("Exiting script...");
					FileSystem.DeleteDirectory(absoluteDownloadsPath);
					return false;
				else
					Script.SetStatus("");
					if successfulMove == true and gAbortedOperation == false then
						installSuccess = true;
					else
						Script.ShowMessageBox("ERROR", "Installation failed!", "OK");
						FileSystem.DeleteDirectory(absoluteDownloadsPath);
						return false;
					end
				end
			else
				installSuccess = false;
				Script.ShowMessageBox("ERROR", "Download failed\n\nPlease try again later...", "OK");
			end
		end
	end

	if installSuccess == true then
		Script.ShowNotification(selection.itemTitle .. " installed");
	end

	FileSystem.DeleteDirectory(absoluteDownloadsPath);
	return true;
end

function HandleAlreadyExists(type, name)
	local msg = "There is a folder that already installed with the name:\n\n" .. name .. "\n\nDo you want to overwrite/replace it?";
	local ret = Script.ShowMessageBox("Item Already Exists", msg, "No", "Yes");
	if ret.Canceled or ret.Button ~= 2 then
		return false;
	end
	return true;
end

function HttpProgressRoutine( dwTotalFileSize, dwTotalBytesTransferred, dwReason )
	if Script.IsCanceled() then
		gAbortedOperation = true;
		Script.SetStatus("Cancelling after this download...");
		Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
        return Cancel;
    end

    Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
	return 0;
end

function CopyProgressRoutine( dwTotalFileSize, dwTotalBytesTransferred )
    if Script.IsCanceled() then
        gAbortedOperation = true;
		Script.SetStatus("Cancelling after this operation...");
		Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
		return Cancel;
    end

    Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
	return 0;
end
