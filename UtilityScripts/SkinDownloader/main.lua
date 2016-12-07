scriptTitle = "Skin Downloader"
scriptAuthor = "Dan Martí"
scriptVersion = 1
scriptDescription = "Download skins for Aurora 0.6b\nfb.com/Danotopia\nWEB: aurorascripts.tuars.com"
scriptIcon = "icon.png";

scriptPermissions = { "http", "filesystem", "sql" }

require("AuroraUI");
require("MenuSystem");
json = require("json");
gizmo = require("Gizmo");

local host = "http://aurorascripts.tuars.com/";

-- Main entry point to script
function main()
	if Aurora.HasInternetConnection() ~= true then
		Script.ShowMessageBox("ERROR", "ERROR: This script requires an active internet connection to work...\n\nPlease make sure you have internet to your console before running the script", "OK");
		return;
	end
	print("-- " .. scriptTitle .. " Started...");
	-- init();
	
	local upd=CheckUpdate();
	if upd then
		goto mainend;
	end
	Script.CreateDirectory( "Screenshots" );
	MakeMainMenu();
	DoShowMenu();
	
	::mainend::
	Script.RefreshListOnExit(upd);
	print("-- " .. scriptTitle .. " Ended...");
end

function MakeMainMenu()
	Menu.SetTitle(scriptTitle);
	Menu.SetGoBackText("");
	Script.SetStatus("Downloading Skin List...");
	Script.SetProgress(0);
	local counter = 1;
	local http = Http.Get(host .. "skins.php");
	
	if http.Success then
		lista = json:decode(http.OutputData);
		for k, v in pairs(lista.skins) do
		-- for _, v in pairs(ini:GetAllSections()) do
			local autor = v.autor;
			local nombre = v.nombre;
			local version = v.version;
			Menu.AddMainMenuItem(Menu.MakeMenuItem(nombre .. " v" .. version .. " by " .. autor, lista.skins[counter]))
			counter = counter + 1;
		end
		
	else
		Script.ShowMessageBox("ERROR", "An error occurred while downloading repo data...\n\nPlease try again later", "OK");
	end
end

function DoShowMenu()
	local ret = {}
	local canceled = false;
	local menuItem = {}
	local menu = "";
	ret, menu, canceled, menuItem = Menu.ShowMainMenu();
	if not canceled then
		HandleSelection(ret, menu.Data, menu);
	end
end

local function roundToNthDecimal(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult + 0.5) / mult
end

function HandleSelection(selection, repo, menu)
	local id = selection.id;
	local hash = selection.hash;
	local nombre = selection.nombre;
	local autor = selection.autor;
	local archivo = selection.archivo
	local version = selection.version
	local tamano = selection.size
	local filename = "Screenshots\\" .. id .. "_" .. version .. ".jpg";
	if Script.FileExists( filename ) == false then
		Script.SetProgress(25);
		Script.SetStatus("Downloading screenshot...");
		local httpImg = Http.Get( host .. "skins/" .. id .. ".jpg", filename );
		if httpImg.Success == true then
		  print("image '" .. filename .. "' download successfully" );
		else
		  FileSystem.DeleteFile(Script.GetBasePath() .. "Screenshots\\".. id .. "_" .. version .. ".jpg");
		  Script.ShowNotification("Screenshot download failed!");
		  print("image '" .. filename .. "' download failed" );
		end
	end
	Script.SetProgress(50);
	Script.SetStatus("Loading script Info...");
	::showui::
	Script.SetProgress(100);
	local cmd = gizmo.run( selection );
	if cmd.Result == "moreinfo" then
		Script.ShowMessageBox("Skin Information", "Name: " .. selection.nombre .. "\nAuthor: " .. selection.autor .. "\nVersion: " .. selection.version .. "\nFile Name: " .. selection.archivo .. "\nFile Size: " .. roundToNthDecimal((tonumber(selection.size)/1024)/1024,2) .. "Mb", "OK");
		goto showui;
	end
    if cmd.Result == "download" then
		Script.SetProgress(0);
		Script.SetStatus("Downloading skin " .. nombre .. "...");
		if FileSystem.FileExists("Game:\\Skins\\" .. archivo) then
			if FileSystem.GetFileSize("Game:\\Skins\\" .. archivo) == tamano then
				local ret = Script.ShowMessageBox("", "The skin is already in the skins folder, do you want to apply it?", "Yes", "No");
				if ret.Button == 1 then
				  local apply = Sql.Execute("UPDATE SystemSettings SET Value='" .. archivo .. "' WHERE Name='Skin'");
				  if apply == true then
					print(archivo .. " apply succesful" ); 
					local ret = Script.ShowMessageBox("", "Done! The skin has been applied, you want to restart Aurora?", "Yes", "No");
					if ret.Button == 1 then
					  print("Restarting" ); 
					  Aurora.Restart();
					end
				  else
					print(archivo .. " apply failed" ); 
					Script.ShowMessageBox("", "The skin cannot be applied, apply it manually from the Aurora's file manager, it's in the Download folder on the script's root", "OK");
				  end
				  goto skipdownload;
				else
				  goto skipdownload;
				end
			else
				local ret = Script.ShowMessageBox("", "The skin is already in the skins folder but it is another version, do you want to download it anyway?", "Yes", "No");
				if ret.Button ~= 1 then
					goto skipdownload;
				end
			end
		end
		Script.CreateDirectory( "Downloads" );
		local filename = "Downloads\\" .. archivo;
		local httpDownload = Http.Get( host .. "skins/" .. id .. ".xzp", filename );
		if httpDownload == nil then
			print("Error Downloading: H: " .. host .. "; ID: " .. id);
			Script.ShowMessageBox("Error", "There was an error trying to download the script", "OK");
			return false;
		end
		if httpDownload.Success == true then
		  local fhash=Aurora.Md5HashFile(httpDownload.OutputPath);
		  if fhash~=hash then
			Script.SetStatus("Download failed!");
			Script.SetProgress(0);
			print("MD5 failed: got(" .. fhash .. ") expected(".. hash .. ")");
			Script.ShowMessageBox("", "The skin cannot be downloaded, see the FAQ on the website", "OK");
			goto skipdownload;
		  end
		  Script.SetStatus("Downloaded! Copying...");
		  Script.SetProgress(90);
		  local result = FileSystem.MoveFile(httpDownload.OutputPath, "Game:\\Skins\\" .. archivo, true);
		  if result == false then
			print(archivo .. " copy failed" );
			Script.ShowMessageBox("", "The skin cannot be moved, move it manually to the skins folder", "OK");
		  else
			print(archivo .. " copy successfully" );
			local ret = Script.ShowMessageBox("", nombre .. " has been downloaded, do you want to apply it?", "Yes", "No");
			if ret.Button == 1 then
			  local apply = Sql.Execute("UPDATE SystemSettings SET Value='" .. archivo .. "' WHERE Name='Skin'");
			  
			  if apply == true then
				print(archivo .. " apply succesful" ); 
				local ret = Script.ShowMessageBox("", "Done! The skin has been applied, you want to restart Aurora?", "Yes", "No");
				if ret.Button == 1 then
				  FileSystem.DeleteFile(httpDownload.OutputPath);
				  print("Restarting" ); 
				  Aurora.Restart();
				end
			  else
				print(archivo .. " apply failed" ); 
				Script.ShowMessageBox("", "The skin cannot be applied, apply it manually from the Aurora menu", "OK");
			  end
			end
		  end
		else
		  print(filename .. " download failed" ); 
		  Script.ShowMessageBox("", "There was an error downloading, try again later", "OK");
		end
	end
	::skipdownload::
	FileSystem.DeleteDirectory(Script.GetBasePath() .. "Downloads" );
	Script.SetStatus("Loading menu...");
	DoShowMenu();
end

function HandleZipInstall(selection, path, type)
	local installPath = path;
	Script.SetStatus("Downloading Script...");
	Script.SetProgress(0);
	local dlpath = "tmp.7z";
	local http = Http.Get(selection.zipurl, dlpath);
	if http.Success then
		Script.SetStatus("Extracting Script...");
		Script.SetProgress(25);
		local zip = ZipFile.OpenFile(dlpath);
		if zip == nil then
			Script.ShowMessageBox("ERROR", "Extraction failed!", "OK");
			return false;
		end
		local result = zip.Extract(zip, "tmp\\");
		FileSystem.DeleteFile(http.OutputPath);
		if result == false then
			Script.ShowMessageBox("ERROR", "Extraction failed!", "OK");
		else
			Script.SetStatus("Installing Script...");
			Script.SetProgress(75);
			result = FileSystem.MoveDirectory(installPath .. "tmp\\", installPath, true);
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

function CheckUpdate()
	local url = host .. "Update.ini";
	Script.SetStatus("Downloading Update information...");
	Script.SetProgress(0);
	local http = Http.Get(url);
	if http == nil then
		Script.ShowNotification("Error connecting to the server...");
		return false;
	end
	if http.Success then
		Script.SetStatus("Parsing Update information...");
		Script.SetProgress(50);
		local ini = IniFile.LoadString(http.OutputData);
		local section = ini:GetSection("SkinDownloader");
		if tonumber(section.scriptVersion) > tonumber(scriptVersion) then
			local ret;
			if section.required=="1" then
				ret = Script.ShowMessageBox("Skin Downloader update available", "An update of Skin Downloader is required (v".. section.scriptVersion ..").\nDo you want to download it?", "Yes", "No");
				if ret.Button == 2 then
					refreshRequired = true
					return refreshRequired;
				end
			else
				ret = Script.ShowMessageBox("Skin Downloader update available", "A new version of Skin Downloader is available (v".. section.scriptVersion .."), do you want to download it?", "Yes", "No");
			end
			if ret.Button == 1 then
				refreshRequired = HandleZipInstall(section, Script.GetBasePath(), "");
				return refreshRequired;
			end
		end
		Script.SetStatus("Update check finished...");
		Script.SetProgress(100);
	else
		Script.ShowNotification("Error downloading update information...");
	end
	return false;
end
