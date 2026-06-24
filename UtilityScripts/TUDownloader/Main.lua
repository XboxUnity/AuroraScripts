scriptTitle = "Title Update Downloader"
scriptAuthor = "Swizzy & EccentricVamp"
scriptVersion = 1
scriptDescription = "Temporary fix for Aurora 0.7b2 and earlier: browse your installed games, download their Title Updates from XboxUnity. Works around the broken native TU hash check."
scriptIcon = "icon.png"
scriptPermissions = { "http", "filesystem", "content", "sql" }

require("MenuSystem");
local JSON = require("JSON");

-- Aurora's Http.Get can return the response body with leftover buffer bytes
-- appended after the actual content (e.g. {"md5":...}<garbage>). The JSON parser
-- still parses the valid leading value correctly, so tolerate the trailing
-- garbage instead of erroring out on it.
function JSON:onTrailingGarbage(json_text, location, parsed_value, etc)
	return parsed_value;
end

local API_BASE = "http://xboxunity.net/api";

local games = {};
local downloadsRel = "Downloads\\";

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Mirror Aurora's FormatFileSize so the stored FileSize string matches native.
local function FormatSize(bytes)
	bytes = tonumber(bytes) or 0;
	if bytes < 1024 then
		return string.format("%d B", bytes);
	elseif bytes < 1048576 then
		return string.format("%.1f KB", bytes / 1024);
	elseif bytes < 1073741824 then
		return string.format("%.1f MB", bytes / 1048576);
	end
	return string.format("%.1f GB", bytes / 1073741824);
end

-- Escape a Lua string for use inside a single-quoted SQLite literal.
local function SqlStr(s)
	return "'" .. tostring(s):gsub("'", "''") .. "'";
end

-- Store a DWORD the same way Aurora's BindInt does (signed 32-bit), so the
-- value round-trips identically to a native title update entry.
local function Int32(n)
	n = (tonumber(n) or 0) % 4294967296;
	if n >= 2147483648 then
		n = n - 4294967296;
	end
	return string.format("%d", n);
end

-- LivePath as Aurora stores it: filename starting "TU_" -> cache, else content.
local function LivePathFor(titleId, filename)
	if string.sub(filename, 1, 3) == "TU_" then
		return "\\Cache\\";
	end
	return string.format("\\Content\\0000000000000000\\%08X\\000B0000\\", titleId);
end

local function PromptContentDrive()
	local drives = FileSystem.GetDrives(true); -- content-capable drives only
	local names = {};
	for i, d in ipairs(drives) do
		local label = d.MountPoint;
		if d.Name ~= nil and d.Name ~= "" then
			label = label .. "  (" .. d.Name .. ")";
		end
		names[i] = label;
	end
	local pick = Script.ShowPopupList("Select the drive to install to", "No content drives found", names);
	if pick.Canceled then
		return nil;
	end
	return drives[pick.Selected.Key];
end

local function HttpJson(url)
	local ret = Http.Get(url);
	if ret ~= nil and ret.Success == true then
		return JSON:decode(ret.OutputData);
	end
	return nil;
end

local function HashesMatch(a, b)
	return a ~= nil and b ~= nil and string.lower(a) == string.lower(b);
end

-- Set of TU hashes already registered in Aurora's database for a title.
local function GetInstalledHashes(titleId)
	local set = {};
	local rows = Sql.ExecuteFetchRows("SELECT Hash FROM TitleUpdates WHERE TitleId = " .. Int32(titleId));
	if type(rows) == "table" then
		for _, row in ipairs(rows) do
			if row.Hash ~= nil then
				set[string.lower(row.Hash)] = true;
			end
		end
	end
	return set;
end

-- ---------------------------------------------------------------------------
-- Install flow
-- ---------------------------------------------------------------------------

function HandleTitleUpdate(game, tu)
	local info = "Game: " .. game.Name .. "\n";
	info = info .. "Title Update: " .. tostring(tu.version) .. "\n";
	info = info .. "Size: " .. FormatSize(tu.filesize) .. "\n";
	info = info .. "File: " .. tostring(tu.filename) .. "\n\n";
	info = info .. "Download, verify and install this title update?";
	local confirm = Script.ShowMessageBox("Title Update", info, "Yes", "No");
	if confirm.Button ~= 1 then
		return;
	end

	local drive = PromptContentDrive();
	if drive == nil then
		return;
	end

	-- Cache title updates can't live on USB storage (matches native behaviour).
	local isCacheTU = string.sub(tu.filename, 1, 3) == "TU_";
	if isCacheTU and string.find(string.lower(drive.MountPoint), "usb") == 1 then
		Script.ShowMessageBox("ERROR", "Cache title updates cannot be installed to a USB drive.\n\nPlease choose an internal (HDD) drive.", "OK");
		return;
	end

	-- Resolve paths up front. Like native, we only write the backup copy here;
	-- Aurora copies it to the live location (LivePath) when the TU is activated.
	local livePath = LivePathFor(game.TitleId, tu.filename);          -- stored in DB only
	local backupDir = string.format("Game:\\Data\\TitleUpdates\\%s\\%08X\\%s\\", drive.Serial, game.TitleId, tu.tuhash);
	local backupFile = backupDir .. tu.filename;

	-- The expected whole-file MD5 (same value as the X-Content-MD5 header, which
	-- Lua can't read). Used to verify both an existing backup and a fresh download.
	Script.SetStatus("Checking title update...");
	Script.SetProgress(10);
	local meta = HttpJson(API_BASE .. "/tumd5/" .. tostring(tu.TitleUpdateID));
	if meta == nil or meta.md5 == nil then
		Script.ShowMessageBox("ERROR", "Could not retrieve the verification hash from the server.\n\nPlease try again later.", "OK");
		return;
	end

	-- Reuse the backup copy if this exact version is already there and valid;
	-- otherwise download it (backups are per-hash, so versions never collide).
	FileSystem.CreateDirectory(backupDir);
	if not (FileSystem.FileExists(backupFile) and HashesMatch(Aurora.Md5HashFile(backupFile), meta.md5)) then
		Script.CreateDirectory("Downloads");
		local relPath = downloadsRel .. tu.filename;
		Script.SetStatus("Downloading " .. tu.filename .. "...");
		Script.SetProgress(20);
		local dl = Http.Get(tu.url, relPath);
		if dl == nil or dl.Success ~= true then
			Script.ShowMessageBox("ERROR", "The title update could not be downloaded.\n\nPlease try again later.", "OK");
			FileSystem.DeleteDirectory(Script.GetBasePath() .. downloadsRel);
			return;
		end

		Script.SetStatus("Verifying download...");
		Script.SetProgress(70);
		local got = Aurora.Md5HashFile(dl.OutputPath);
		if not HashesMatch(got, meta.md5) then
			print("TUDownloader: MD5 mismatch got(" .. tostring(got) .. ") expected(" .. tostring(meta.md5) .. ")");
			Script.SetStatus("Verification failed!");
			Script.SetProgress(0);
			Script.ShowMessageBox("Verification failed", "The downloaded title update's hash did not match the server.\n\nThe file was discarded.", "OK");
			FileSystem.DeleteDirectory(Script.GetBasePath() .. downloadsRel);
			return;
		end

		-- Verified: move it into its per-hash backup folder (overwrite any partial).
		if FileSystem.MoveFile(dl.OutputPath, backupFile, true) ~= true then
			Script.ShowMessageBox("ERROR", "The title update was verified but could not be saved to:\n" .. backupFile, "OK");
			FileSystem.DeleteDirectory(Script.GetBasePath() .. downloadsRel);
			return;
		end
		FileSystem.DeleteDirectory(Script.GetBasePath() .. downloadsRel);
	end

	-- Register it in Aurora's database (same row a native download writes), unless
	-- this exact version is already registered for this drive.
	Script.SetStatus("Adding to database...");
	Script.SetProgress(90);
	local exists = Sql.ExecuteFetchRows(string.format(
		"SELECT Id FROM TitleUpdates WHERE TitleId = %s AND Hash = %s AND LiveDeviceId = %s",
		Int32(game.TitleId), SqlStr(tu.tuhash), SqlStr(drive.Serial)));
	local alreadyRegistered = (type(exists) == "table" and #exists > 0);

	if not alreadyRegistered then
		local insert = "INSERT INTO TitleUpdates (FileName, LiveDeviceId, LivePath, TitleId, Version, Hash, BackupPath, BaseVersion, DisplayName, MediaId, FileSize) VALUES ("
			.. SqlStr(tu.filename) .. ", "
			.. SqlStr(drive.Serial) .. ", "
			.. SqlStr(livePath) .. ", "
			.. Int32(game.TitleId) .. ", "
			.. Int32(tu.version) .. ", "
			.. SqlStr(tu.tuhash) .. ", "
			.. SqlStr(backupFile) .. ", "
			.. Int32(game.BaseVersion) .. ", "
			.. SqlStr(game.Name) .. ", "
			.. Int32(game.MediaId) .. ", "
			.. SqlStr(FormatSize(tu.filesize)) .. ")";
		if Sql.Execute(insert) ~= true then
			Script.ShowMessageBox("ERROR", "The title update was installed but could not be added to Aurora's database.", "OK");
			return;
		end
	end

	Script.SetStatus("Done!");
	Script.SetProgress(100);
	local msg;
	if alreadyRegistered then
		msg = "Title update verified and already in Aurora's database.";
	else
		msg = "Title update verified and added to Aurora's database.";
	end
	local restart = Script.ShowMessageBox("Success", msg .. "\n\nRestart Aurora to load it, then enable it from the game's Title Updates menu. Restart now?", "Yes", "No");
	if restart.Button == 1 then
		Aurora.Restart();
	end
end

function HandleGame(game)
	local listUrl = string.format("%s/tu/%08X/%08X", API_BASE, game.TitleId, game.BaseVersion);
	Script.SetStatus("Fetching title updates for " .. game.Name .. "...");
	Script.SetProgress(0);

	local tus = HttpJson(listUrl);
	if type(tus) ~= "table" or #tus == 0 then
		Script.ShowMessageBox(game.Name, "No title updates were found for this game on XboxUnity.", "OK");
		return;
	end

	local installed = GetInstalledHashes(game.TitleId);
	local display = {};
	for i, tu in ipairs(tus) do
		local mark = "";
		if tu.tuhash ~= nil and installed[string.lower(tu.tuhash)] then
			mark = "√ ";
		end
		display[i] = mark .. "Title Update " .. tostring(tu.version) .. "   (" .. FormatSize(tu.filesize) .. ")";
	end

	local pick = Script.ShowPopupList("Title Updates - " .. game.Name, "No title updates found", display);
	if pick.Canceled then
		return;
	end
	HandleTitleUpdate(game, tus[pick.Selected.Key]);
end

-- ---------------------------------------------------------------------------
-- Menu / entry point
-- ---------------------------------------------------------------------------

function BuildGamesList()
	local seen = {};
	local collection = Content.FindContent();
	for i = 1, #collection do
		local item = collection[i];
		if item.TitleId ~= nil and item.TitleId ~= 0 then
			local key = string.format("%08X_%08X", item.TitleId, item.BaseVersion);
			if seen[key] == nil then
				seen[key] = true;
				table.insert(games, {
					Name = item.Name,
					TitleId = item.TitleId,
					MediaId = item.MediaId,
					BaseVersion = item.BaseVersion,
				});
			end
		end
	end
	return #games > 0;
end

function MakeMainMenu()
	Menu.ResetMenu();
	Menu.SetTitle(scriptTitle);
	Menu.SetGoBackText("");
	for _, game in ipairs(games) do
		Menu.AddMainMenuItem(Menu.MakeMenuItem(game.Name, game));
	end
end

function DoShowMenu()
	local selection, _, canceled = Menu.ShowMainMenu();
	if not canceled then
		HandleGame(selection);
		DoShowMenu();
	end
end

function main()
	if Aurora.HasInternetConnection() ~= true then
		Script.ShowMessageBox("ERROR", "This script requires an active internet connection.\n\nPlease connect your console to the internet and try again.", "OK");
		return;
	end

	print("-- " .. scriptTitle .. " Started...");
	if BuildGamesList() then
		MakeMainMenu();
		DoShowMenu();
	else
		Script.ShowMessageBox(scriptTitle, "No installed games were found in your library to look up title updates for.", "OK");
	end
	FileSystem.DeleteDirectory(Script.GetBasePath() .. downloadsRel);
	print("-- " .. scriptTitle .. " Ended...");
end
