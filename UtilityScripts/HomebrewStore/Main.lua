scriptTitle = "Homebrew Store"
scriptAuthor = "Derf / Cheato / Eduardo Henrique"
scriptVersion = 6
scriptDescription = "Download homebrew from ConsoleMods.org and other repos! (Optimized Version)"
scriptIcon = "icon.png"
scriptPermissions = { "http", "sql", "filesystem" }
--Built from AuroraRepo. Please be gentle :)
require("MenuSystem");

local reloadRequired = false;
local downloadsPath = "Downloads\\";
local gAbortedOperation = false;
local absoluteDownloadsPath = "";
local scanPathCache = nil;

-- Unified temporary cleanup function (DRY / Reduced redundancy)
local function Cleanup()
	if absoluteDownloadsPath ~= nil and absoluteDownloadsPath ~= "" then
		FileSystem.DeleteDirectory(absoluteDownloadsPath);
	end
end

-- Local ScanPaths cache to avoid repeatedly executing heavy SQL queries
local function LoadScanPaths()
	if scanPathCache ~= nil then
		return scanPathCache
	end

	scanPathCache = {}

	-- MountPoint cache by DeviceId for ultra-fast O(1) lookups
	local mountPoints = {}
	local devices = Sql.ExecuteFetchRows("SELECT DeviceId, MountPoint FROM MountedDevices")
	if devices ~= nil then
		for _, d in pairs(devices) do
			if d.DeviceId ~= nil and d.MountPoint ~= nil then
				mountPoints[d.DeviceId] = d.MountPoint
			end
		end
	end

	-- Retrieve and map all ScanPaths in a single pass
	local paths = Sql.ExecuteFetchRows("SELECT Path, DeviceId, ScriptData FROM ScanPaths")
	if paths ~= nil then
		for _, p in pairs(paths) do
			local mountpoint = mountPoints[p.DeviceId]
			if mountpoint ~= nil then
				local fullPath = mountpoint .. p.Path .. "\\"
				if p.ScriptData == "Applications" then
					scanPathCache["App"] = fullPath
				elseif p.ScriptData == "Homebrew" then
					scanPathCache["Homebrew"] = fullPath
				elseif p.ScriptData == "Emulators" then
					scanPathCache["Emulator"] = fullPath
				elseif p.ScriptData == "Games" then
					scanPathCache["Game"] = fullPath
				elseif p.ScriptData == "Live" then
					scanPathCache["PublicProfile"] = fullPath
				end
			end
		end
	end

	return scanPathCache
end

function GetScanPath(type)
	local cache = LoadScanPaths()
	return cache[type]
end

-- Main entry point to script
function main()
	if Aurora.HasInternetConnection() ~= true then
		Script.ShowMessageBox("ERROR", "This script requires an active internet connection to work...\n\nPlease make sure your console is connected to the internet before running the script.", "OK");
		return;
	end
	print("-- " .. scriptTitle .. " started...");

	if init() == false then
		goto scriptend;
	end

	local g_RestartMenu = true
	while g_RestartMenu do
		g_RestartMenu = false
		Menu.ResetMenu();
		MakeMainMenu();
		DoShowMenu();
	end

	if reloadRequired and not gAbortedOperation then
		local ret = Script.ShowMessageBox(
			"Aurora Reload Required",
			"A reload is required for your changes to take effect...\n\nDo you want to reload Aurora now?",
			"Yes",
			"No"
		);

		if ret.Button == 1 then
			Aurora.Restart();
		end
	end

	::mainend::
	Cleanup();
	print("-- " .. scriptTitle .. " ended...");
	::scriptend::
end

-- Dynamic device prompt using the native Aurora FileSystem API
function PromptContentDrive()
	local drives = FileSystem.GetDrives(true); -- Content-capable drives only
	local names = {};

	for i, d in ipairs(drives) do
		local label = d.MountPoint;
		if d.Name ~= nil and d.Name ~= "" then
			label = label .. "  (" .. d.Name .. ")";
		end
		names[i] = label;
	end

	local pick = Script.ShowPopupList(
		"Select the drive to install to",
		"No content drives found",
		names
	);

	if pick.Canceled then
		return nil;
	end

	local d = drives[pick.Selected.Key]
	return d;
end

function init()
	-- Remove unfinished downloads
	absoluteDownloadsPath = Script.GetBasePath() .. downloadsPath;
	Cleanup();
	FileSystem.CreateDirectory(absoluteDownloadsPath);

	-- Update saved repositories
	Script.SetStatus("Updating repositories...");
	Script.SetProgress(5);
	local updatingIndex = 0;

	local reposPath = Script.GetBasePath() .. "Repos"
	if not FileSystem.FileExists(reposPath) then
		FileSystem.CreateDirectory(reposPath)
	end

	local repos = FileSystem.GetFiles(reposPath .. "\\*");
	if repos ~= nil then
		for i, repo in pairs(repos) do
			local repoDisplayName = repo.Name:gsub("%.ini$", "");
			Script.SetStatus("Updating " .. repoDisplayName .. "...");
			updatingIndex = updatingIndex + 1;

			if updatingIndex < 6 then
				Script.SetProgress(5 + (15 * updatingIndex));
			end

			local remoteRepoIniToUpdate = IniFile.LoadFile("Repos\\" .. repo.Name);
			if remoteRepoIniToUpdate ~= nil then
				local remoteRepoIniSection = remoteRepoIniToUpdate:GetSection("update");

				if remoteRepoIniSection ~= nil then
					local repourl = remoteRepoIniSection.repourl;
					if repourl ~= nil then
						local http = Http.Get(repourl, "\\Repos\\" .. repo.Name);
						if not http.Success then
							Script.ShowMessageBox("ERROR", "Could not connect to " .. repoDisplayName, "OK");
						end
					end
				end
			end
		end
	end
end

function MakeMainMenu()
	Menu.SetTitle(scriptTitle);
	Menu.SetGoBackText("");

	local reposPath = Script.GetBasePath() .. "Repos"
	if not FileSystem.FileExists(reposPath) then
		FileSystem.CreateDirectory(reposPath)
	end

	local repos = FileSystem.GetFiles(reposPath .. "\\*");
	if repos ~= nil then
		for i, repo in pairs(repos) do
			local remoteRepoIni = IniFile.LoadFile("Repos\\" .. repo.Name);
			if remoteRepoIni ~= nil then
				local remoteRepoIniSections = remoteRepoIni:GetAllSections();

				if remoteRepoIniSections ~= nil then
					for _, v in pairs(remoteRepoIniSections) do
						local title = remoteRepoIni:ReadValue(v, "name", "");
						if title ~= "" then
							Menu.AddMainMenuItem(Menu.MakeMenuItem(title, remoteRepoIni:GetSection(v)));
						end
					end
				end
			end
		end
	end

	Menu.AddMainMenuItem(Menu.MakeMenuItem("<enter URL>", {
		["name"] = "test",
		["iniurl"] = "ENTER_URL",
	}));
end

function DoShowMenu(menu)
	if gAbortedOperation or g_RestartMenu then
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

			if (ret.iniurl == "ENTER_URL") then
				-- Prompt the user for the .ini file URL
				local keyboardData = Script.ShowKeyboard(
					"Aurora Keyboard",
					"Enter the full URL to a valid .ini file",
					"https://",
					0
				);

				if keyboardData.Canceled == false then
					iniurl = keyboardData.Buffer;
				else
					return;
				end

				local iniRepoPath = Script.GetBasePath() .. "Repos\\";
				FileSystem.CreateDirectory(iniRepoPath);
				local newRepoName = string.match(iniurl, "^https?://([^/]+)");
				http = Http.Get(iniurl, "\\Repos\\" .. newRepoName .. ".ini");

				if http.Success then
					Script.ShowNotification(newRepoName .. " repo installed!");
				else
					Script.ShowMessageBox("ERROR", "Failed to download the .ini file:\n\n" .. iniurl, "OK");
				end

				return
			else
				-- Load the .ini file from the repository entry
				http = Http.Get(ret.iniurl);
				if http.Success then
					Script.SetStatus("Processing listings...");
					Script.SetProgress(50);

					local ini = IniFile.LoadString(http.OutputData);

					for _, v in pairs(ini:GetAllSections()) do
						local title = ini:ReadValue(v, "itemTitle", "");
						local ver = ini:ReadValue(v, "itemVersion", "");
						local author = ini:ReadValue(v, "itemAuthor", "");

						if (title ~= "" and ver ~= "" and author ~= "") then
							Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem(title .. " (v" .. ver .. ")", ini:GetSection(v)));
						elseif (title ~= "") then
							Menu.AddSubMenuItem(menuItem, Menu.MakeMenuItem(title, ini:GetSection(v)));
						end
					end
				else
					Script.ShowMessageBox(
						"ERROR",
						"An error occurred while downloading the store data...\n\nPlease try again later.",
						"OK"
					);
					DoShowMenu(menu);
					return;
				end
			end
		end

		if g_RestartMenu then
			return;
		end

		if menuItem.SubMenu ~= nil then
			-- Open submenu
			DoShowMenu(menuItem.SubMenu);

			if g_RestartMenu then
				return;
			end

		elseif not Menu.IsMainMenu(menu) then
			-- Content item selected
			HandleSelection(ret, menu.Parent.Data, menu);

		else
			Script.ShowMessageBox(
				"ERROR",
				"An unknown error occurred!\n\nExiting...",
				"OK"
			);
		end
	end
end

function HandleSelection(selection, repo, menu)
	local info = "";

	-- Prompt the user to select a drive before showing the download confirmation
	local drive = PromptContentDrive();
	if drive == nil then
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

	-- Compute the correct destination path using the selected drive mount point
	local destinationPath = GetDestinationPath(selection.path, repo.type, drive.MountPoint);

	if destinationPath ~= nil and destinationPath ~= "" then
		info = info .. "Path: " .. destinationPath .. "\n";
	else
		return nil;
	end

	if selection.itemDescription ~= nil and selection.itemDescription ~= "" then
		info = info .. "Description:\n" .. string.gsub(selection.itemDescription, "\\n", "\n") .. "\n\n";
	end

	info = info .. "\n\n\nDo you want to install this " .. repo.type .. " on " .. drive.MountPoint:gsub("\\", "") .. "?";

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

function ReplaceMount(originalPath, mountPoint)
	if mountPoint ~= nil and string.sub(mountPoint, -1) ~= "\\" then
		mountPoint = mountPoint .. "\\"
	end

	local pathOnly = originalPath:gsub("^[^:]+:[\\/]?", "")

	if string.sub(pathOnly, 1, 1) ~= "\\" then
		pathOnly = "\\" .. pathOnly
	end

	if string.sub(pathOnly, -1) ~= "\\" then
		pathOnly = pathOnly .. "\\"
	end

	return mountPoint .. pathOnly
end

function GetDestinationPath(path, type, mountPoint)
	-- If ScanPaths are not configured in Aurora settings:
	-- App           - Installs to /Apps/
	-- Game          - Installs to /Games/
	-- Emulator      - Installs to /Emulators/
	-- PublicProfile - Installs to /Content/0000000000000000/
	-- Profile       - Installs to /Content/<profile ID>/ of the signed-in user
	-- Other         - Uses the full path specified in the .ini file

	if mountPoint ~= nil and string.sub(mountPoint, -1) ~= "\\" then
		mountPoint = mountPoint .. "\\"
	end

	local applicationsDirectory = GetScanPath("App");
	local gamesDirectory = GetScanPath("Game");
	local homebrewDirectory = GetScanPath("Homebrew");
	local emulatorsDirectory = GetScanPath("Emulator");

	if type == "App" then
		if applicationsDirectory ~= nil then
			return ReplaceMount(applicationsDirectory, mountPoint) .. path;
		else
			return mountPoint .. "Apps\\" .. path;
		end

	elseif type == "Game" then
		if gamesDirectory ~= nil then
			return ReplaceMount(gamesDirectory, mountPoint) .. path;
		else
			return mountPoint .. "Games\\" .. path;
		end

	elseif type == "Emulator" then
		if emulatorsDirectory ~= nil then
			return ReplaceMount(emulatorsDirectory, mountPoint) .. path;
		else
			return mountPoint .. "Emulators\\" .. path;
		end

	elseif type == "Homebrew" then
		if homebrewDirectory ~= nil then
			return ReplaceMount(homebrewDirectory, mountPoint) .. path;
		else
			return mountPoint .. "Homebrew\\" .. path;
		end

	elseif type == "PublicProfile" then
		return mountPoint .. "Content\\0000000000000000\\" .. path;

	elseif type == "Profile" then
		local profileID = Profile.GetXUID(1);

		if profileID == "0" then
			Script.ShowMessageBox(
				"ERROR",
				"You need to sign in to a profile to download content from this category.",
				"OK"
			);
		else
			if string.len(profileID) == 16 then
				return mountPoint .. "Content\\" .. Profile.GetXUID(1) .. "\\" .. path;
			else
				-- When signed in to Xbox Live, the profile XUID becomes a 13-character string
				local profiles = Profile.EnumerateProfiles();

				for i, profile in pairs(profiles) do
					if profile.GamerTag == Profile.GetGamerTag(1) then
						return mountPoint .. "Content\\" .. profile.XUID .. "\\" .. path;
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
			Script.ShowMessageBox("ERROR", "This download requires a USB flash drive. Please plug one in and try again.", "OK");
			return nil;
		end
	end

	local filename = selection.path;
	if FileSystem.FileExists(destinationPath) then
		if not HandleAlreadyExists(type, filename) then
			return false; -- Installation canceled by the user
		end
	end

	FileSystem.CreateDirectory(destinationPath);
	Script.SetProgress(10);

	local destinationFullPath = "";
	local partFileName = "";
	local updatingIndex = 0;
	local loadingProgress = 0;
	local installSuccess = false;
	gAbortedOperation = false;

	-- 7z files must be smaller than 350 MB, otherwise Aurora's extractor fails

	-- Add the main dataurl first
	local dataurls = {}
	for key in pairs(selection) do
		if string.match(key, "^dataurl$") then
			table.insert(dataurls, key);
			break;
		end
	end

	-- Add multipart data URLs sequentially
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

		-- If this is a multipart file, determine its destination path
		if string.match(dataurl_name, "part") then
			local partname = string.sub(dataurl_name, 8, -1);
			destinationFullPath = "";

			for key2, partpath in pairs(selection) do
				if string.match(key2, partname .. "path") then
					destinationFullPath = GetDestinationPath(partpath, type, string.match(destinationPath, "^[^:]+:[\\/]*"));
				end
			end

			if destinationFullPath == "" then
				-- No specific path defined, use the default destination
				destinationFullPath = string.match(destinationPath, "^.+[\\\\]");
			end
		else
			-- Main dataurl uses the default destination
			destinationFullPath = string.match(destinationPath, "^.+[\\\\]");
		end

		FileSystem.CreateDirectory(destinationFullPath);

		if updatingIndex < 8 then
			loadingProgress = 10 + (10 * updatingIndex);
			Script.SetProgress(loadingProgress);
		end

		updatingIndex = updatingIndex + 1;

		-- Download content
		local dlpath = "";
		local successfulMove = false;
		local tmpRandomString = math.random(1, 100000000);

		if string.match(dataurl, ".7z") then
			dlpath = downloadsPath .. "tmp-" .. tmpRandomString .. ".7z";
		else
			dlpath = downloadsPath .. "tmp-" .. tmpRandomString .. ".bin";
		end

		Script.SetStatus("Downloading content (" .. current_part_index .. "/" .. total_parts .. ")...");
		local http = Http.GetEx(dataurl, HttpProgressRoutine, dlpath);

		if gAbortedOperation == true then
			installSuccess = false;
			Script.ShowNotification("Download canceled");
			Script.SetStatus("Exiting script...");
			Cleanup();
		else
			if http.Success then
				Script.SetProgress(loadingProgress + 5);

				if string.match(dataurl, ".7z") then
					-- Extract archive
					local zip = ZipFile.OpenFile(dlpath);

					if zip == nil then
						Script.ShowMessageBox("ERROR", "Could not open archive!", "OK");
						return false;
					end

					Script.SetStatus("Extracting content (" .. current_part_index .. "/" .. total_parts .. ")...");
					local result = zip.Extract(zip, downloadsPath .. "tmp\\");

					if result == false then
						Script.ShowMessageBox("ERROR", "Extraction failed!", "OK");
						Cleanup();
						return false;
					else
						Script.SetProgress(loadingProgress + 7);
						Script.SetStatus("Installing content (" .. current_part_index .. "/" .. total_parts .. ")...");

						local source = absoluteDownloadsPath .. "tmp\\";
						local dest = string.match(destinationPath, "^.+[\\]");

						successfulMove = FileSystem.MoveDirectory(
							source,
							dest,
							true,
							CopyProgressRoutine
						);

						Script.SetProgress(loadingProgress + 9);
					end
				else
					-- Copy a single file to the destination
					Script.SetProgress(loadingProgress + 7);
					Script.SetStatus("Moving content (" .. current_part_index .. "/" .. total_parts .. ")...");

					partFileName = string.match(dataurl, "^.*/([^/]+)$");

					successfulMove = FileSystem.CopyFile(
						absoluteDownloadsPath .. "tmp-" .. tmpRandomString .. ".bin",
						destinationFullPath .. partFileName,
						true,
						CopyProgressRoutine
					);

					Script.SetProgress(loadingProgress + 9);
				end

				if gAbortedOperation == true then
					Script.ShowNotification("Operation canceled!");
					Script.SetStatus("Exiting script...");
					Cleanup();
					return false;
				else
					Script.SetStatus("");

					if successfulMove == true and gAbortedOperation == false then
						installSuccess = true;
					else
						Script.ShowMessageBox("ERROR", "Installation failed!", "OK");
						Cleanup();
						return false;
					end
				end
			else
				installSuccess = false;
				Script.ShowMessageBox("ERROR", "Download failed.\n\nPlease try again later...", "OK");
			end
		end
	end

	if installSuccess == true then
		Script.ShowNotification(selection.itemTitle .. " installed");
	end

	Cleanup();
	return true;
end

function HandleAlreadyExists(type, name)
	local msg = "An item with the following name already exists:\n\n" ..
		name ..
		"\n\nDo you want to overwrite/replace it?";

	local ret = Script.ShowMessageBox("Item Already Exists", msg, "No", "Yes");

	if ret.Canceled or ret.Button ~= 2 then
		return false;
	end

	return true;
end

function HttpProgressRoutine(dwTotalFileSize, dwTotalBytesTransferred, dwReason)
	if Script.IsCanceled() then
		gAbortedOperation = true;
		Script.SetStatus("Canceling after this download...");
		Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
		return Cancel;
	end

	Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
	return 0;
end

function CopyProgressRoutine(dwTotalFileSize, dwTotalBytesTransferred)
	if Script.IsCanceled() then
		gAbortedOperation = true;
		Script.SetStatus("Canceling after this operation...");
		Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
		return Cancel;
	end

	Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
	return 0;
end