scriptTitle = "Xefu Spoofer"
scriptAuthor = "Derf"
scriptVersion = 1
scriptDescription = "Forces original Xbox games to use your selected xefu version. Compatibility list: ConsoleMods.org/fusion"
scriptIcon = "icon.png"
scriptPermissions = { "filesystem" }
require("MenuSystem");

compatibility_folder = "Hddx:\\Compatibility\\";
xefubackup_folder = "Hddx:\\Compatibility\\XefuBackup\\";

-- Main entry point to script
function main()
	print("-- " .. scriptTitle .. " Started...");

	if init() == false then
		goto scriptend;
	end

	MakeMainMenu();
	DoShowMenu();
	
	::scriptend::
end

function xefu_files_all_present(path)
	if not (FileSystem.FileExists( path .. "xefu.xex" )
	and FileSystem.FileExists( path .. "xefu2.xex" )
	and FileSystem.FileExists( path .. "xefu3.xex" )
	and FileSystem.FileExists( path .. "xefu5.xex" )
	and FileSystem.FileExists( path .. "xefu1_1.xex" )
	and FileSystem.FileExists( path .. "xefu6.xex" )
	and FileSystem.FileExists( path .. "xefu7.xex" )
	and FileSystem.FileExists( path .. "xefu7b.xex" ) ) then
		if path == compatibility_folder then
			Script.ShowMessageBox("ERROR","Missing xefu .xex files in\nHddx:\\Compatibility!\n\nYou will need to obtain these files before running this script.","OK");
		end
		return false;
	end
	
	if not ( FileSystem.FileExists( path .. "xefutitle5.xex" )
	and FileSystem.FileExists( path .. "xefutitle6.xex" )
	and FileSystem.FileExists( path .. "xefutitle7.xex" )
	and FileSystem.FileExists( path .. "xefutitle7b.xex" ) ) then
		if path == compatibility_folder then
			if FileSystem.FileExists( compatibility_folder .. "xefu_spoofer.txt" ) then
				-- The titlexefu files may not be present if using an early xefu
				return true;
			end
			Script.ShowMessageBox("ERROR","Missing xefutitle .xex files in\nHddx:\\Compatibility!\n\nYou will need to obtain these files before running this script.","OK");
		end
		return false;
	end

	-- Optional new xefu files; copy now in case they were not in previous xefu backup
	if FileSystem.FileExists( compatibility_folder .. "xefu2019.xex" ) and not FileSystem.FileExists( xefubackup_folder .. "xefu2019.xex" ) then
		FileSystem.CopyFile( compatibility_folder .. "xefu2019.xex", xefubackup_folder .. "xefu2019.xex", false );
	end

	if FileSystem.FileExists( compatibility_folder .. "xefu2021.xex" ) and not FileSystem.FileExists( xefubackup_folder .. "xefu2021.xex" ) then
		FileSystem.CopyFile( compatibility_folder .. "xefu2021.xex", xefubackup_folder .. "xefu2021.xex", false );
	end

	-- Optional new xefutitle files
	if FileSystem.FileExists( compatibility_folder .. "xefutitle2019.xex" ) and not FileSystem.FileExists( xefubackup_folder .. "xefutitle2019.xex" ) then
		FileSystem.CopyFile( compatibility_folder .. "xefutitle2019.xex", xefubackup_folder .. "xefutitle2019.xex", false );
	end

	if FileSystem.FileExists( compatibility_folder .. "xefutitle2021.xex" ) and not FileSystem.FileExists( xefubackup_folder .. "xefutitle2021.xex" ) then
		FileSystem.CopyFile( compatibility_folder .. "xefutitle2021.xex", xefubackup_folder .. "xefutitle2021.xex", false );
	end

	return true;
end

function copy_xefu_files(source_folder, target_folder)
	FileSystem.CopyFile( source_folder .. "xefu.xex", target_folder .. "xefu.xex", false );
	FileSystem.CopyFile( source_folder .. "xefu2.xex", target_folder .. "xefu2.xex", false );
	FileSystem.CopyFile( source_folder .. "xefu3.xex", target_folder .. "xefu3.xex", false );
	FileSystem.CopyFile( source_folder .. "xefu5.xex", target_folder .. "xefu5.xex", false );
	FileSystem.CopyFile( source_folder .. "xefu1_1.xex", target_folder .. "xefu1_1.xex", false );
	FileSystem.CopyFile( source_folder .. "xefu6.xex", target_folder .. "xefu6.xex", false );
	FileSystem.CopyFile( source_folder .. "xefu7.xex", target_folder .. "xefu7.xex", false );
	FileSystem.CopyFile( source_folder .. "xefu7b.xex", target_folder .. "xefu7b.xex", false );

	if FileSystem.FileExists( source_folder .. "xefu2019.xex" ) then
		FileSystem.CopyFile( source_folder .. "xefu2019.xex", target_folder .. "xefu2019.xex", false );
	end

	if FileSystem.FileExists( source_folder .. "xefu2021.xex" ) then
		FileSystem.CopyFile( source_folder .. "xefu2021.xex", target_folder .. "xefu2021.xex", false );
	end

	FileSystem.CopyFile( source_folder .. "xefutitle5.xex", target_folder .. "xefutitle5.xex", false );
	FileSystem.CopyFile( source_folder .. "xefutitle6.xex", target_folder .. "xefutitle6.xex", false );
	FileSystem.CopyFile( source_folder .. "xefutitle7.xex", target_folder .. "xefutitle7.xex", false );
	FileSystem.CopyFile( source_folder .. "xefutitle7b.xex", target_folder .. "xefutitle7b.xex", false );

	if FileSystem.FileExists( source_folder .. "xefutitle2019.xex" ) then
		FileSystem.CopyFile( source_folder .. "xefutitle2019.xex", target_folder .. "xefutitle2019.xex", false );
	end

	if FileSystem.FileExists( source_folder .. "xefutitle2021.xex" ) then
		FileSystem.CopyFile( source_folder .. "xefutitle2021.xex", target_folder .. "xefutitle2021.xex", false );
	end
end

function spoof_xefu_files(xefu_name)
	FileSystem.CopyFile( xefubackup_folder .. xefu_name, compatibility_folder .. "xefu.xex", false );
	FileSystem.CopyFile( xefubackup_folder .. xefu_name, compatibility_folder .. "xefu2.xex", false );
	FileSystem.CopyFile( xefubackup_folder .. xefu_name, compatibility_folder .. "xefu3.xex", false );
	FileSystem.CopyFile( xefubackup_folder .. xefu_name, compatibility_folder .. "xefu5.xex", false );
	FileSystem.CopyFile( xefubackup_folder .. xefu_name, compatibility_folder .. "xefu1_1.xex", false );
	FileSystem.CopyFile( xefubackup_folder .. xefu_name, compatibility_folder .. "xefu6.xex", false );
	FileSystem.CopyFile( xefubackup_folder .. xefu_name, compatibility_folder .. "xefu7.xex", false );
	FileSystem.CopyFile( xefubackup_folder .. xefu_name, compatibility_folder .. "xefu7b.xex", false );

	local xefutitle_name = "";
	if xefu_name == "xefu5.xex" then
		xefutitle_name = "xefutitle5.xex";
	elseif xefu_name == "xefu6.xex" then
		xefutitle_name = "xefutitle6.xex";
	elseif xefu_name == "xefu7.xex" then
		xefutitle_name = "xefutitle7.xex";
	elseif xefu_name == "xefu7b.xex" then
		xefutitle_name = "xefutitle7b.xex";
	elseif xefu_name == "xefu2019.xex" then
		xefutitle_name = "xefutitle2019.xex";
	elseif xefu_name == "xefu2021.xex" then
		xefutitle_name = "xefutitle2021.xex";
	end

	if xefutitle_name ~= "" then
		FileSystem.CopyFile( xefubackup_folder .. xefutitle_name, compatibility_folder .. "xefutitle.xex", false );
		FileSystem.CopyFile( xefubackup_folder .. xefutitle_name, compatibility_folder .. "xefutitle5.xex", false );
		FileSystem.CopyFile( xefubackup_folder .. xefutitle_name, compatibility_folder .. "xefutitle6.xex", false );
		FileSystem.CopyFile( xefubackup_folder .. xefutitle_name, compatibility_folder .. "xefutitle7.xex", false );
		FileSystem.CopyFile( xefubackup_folder .. xefutitle_name, compatibility_folder .. "xefutitle7b.xex", false );
	end
end

function delete_xefu_files(target_folder)
	FileSystem.DeleteFile( target_folder .. "xefu.xex" );
	FileSystem.DeleteFile( target_folder .. "xefu2.xex" );
	FileSystem.DeleteFile( target_folder .. "xefu3.xex" );
	FileSystem.DeleteFile( target_folder .. "xefu5.xex" );
	FileSystem.DeleteFile( target_folder .. "xefu1_1.xex" );
	FileSystem.DeleteFile( target_folder .. "xefu6.xex" );
	FileSystem.DeleteFile( target_folder .. "xefu7.xex" );
	FileSystem.DeleteFile( target_folder .. "xefu7b.xex" );

	if FileSystem.FileExists( target_folder .. "xefu2019.xex" ) then
		FileSystem.DeleteFile( target_folder .. "xefu2019.xex" );
	end

	if FileSystem.FileExists( target_folder .. "xefu2021.xex" ) then
		FileSystem.DeleteFile( target_folder .. "xefu2021.xex" );
	end

	FileSystem.DeleteFile( target_folder .. "xefutitle5.xex" );
	FileSystem.DeleteFile( target_folder .. "xefutitle6.xex" );
	FileSystem.DeleteFile( target_folder .. "xefutitle7.xex" );
	FileSystem.DeleteFile( target_folder .. "xefutitle7b.xex" );

	if FileSystem.FileExists( target_folder .. "xefutitle.xex" ) then
		FileSystem.DeleteFile( target_folder .. "xefutitle.xex" );
	end
end

function set_xefuspoofer_txt(xefu_name)
	local text = xefu_name .. "\n\nThe Xefu Spoofer script has currently set all xefu files to point to " .. xefu_name .. " instead of their original file. If you wish to change this, run the Xefu Spoofer script again and reset it to default OR delete the xefu files in this directory and move the ones from XefuBackup to this directory or source a fresh copy of the xefu files."
	FileSystem.WriteFile( compatibility_folder .. "xefu_spoofer.txt", text );
end

function init()
	-- Update default ConsoleMods repo
	Script.SetStatus("Checking Xefu files...");
	Script.SetProgress(25);

	-- Check for Compatibility folder
	if not FileSystem.FileExists(compatibility_folder) then
		Script.ShowMessageBox("ERROR","Hddx:\\Compatibility folder not found!\n\nYou will need to install the backwards compatibility pack.","OK");
		-- Missing Compatibility folder, stop execution
		return false;
	end

	-- Check if user has all xefu files
	if not xefu_files_all_present(compatibility_folder) then
		-- Missing files, stop execution
		return false;
	end

	-- Look in Compatibility folder for XefuBackup
	if FileSystem.FileExists(xefubackup_folder) then
		if xefu_files_all_present(xefubackup_folder) then
			-- All checks OK, proceed
			return true;
		else
			-- Backup xefu files to XefuBackup folder
			Script.SetStatus("Backing up Xefu files...");
			Script.SetProgress(50);
			copy_xefu_files(compatibility_folder, xefubackup_folder);
			Script.SetProgress(100);
			return true;
		end
	else
		-- Backup xefu files to XefuBackup folder
		FileSystem.CreateDirectory( xefubackup_folder );
		Script.SetStatus("Backing up Xefu files...");
		Script.SetProgress(50);
		copy_xefu_files(compatibility_folder, xefubackup_folder);
		Script.SetProgress(100);
		return true;
	end
end

function MakeMainMenu()
	-- Display currently spoofed xefu file in title of window
	if FileSystem.FileExists( compatibility_folder .. "xefu_spoofer.txt" ) then
		local text = FileSystem.ReadFile( compatibility_folder .. "xefu_spoofer.txt" );
		Menu.SetTitle(scriptTitle .. " - Currently set to " .. text:match("^(.-)\n"));
	else
		Menu.SetTitle(scriptTitle .. " - Currently set to default");
	end

	Menu.SetGoBackText("");

	-- Populate menu
	Menu.AddMainMenuItem(Menu.MakeMenuItem("<reset to default>", "RESET" ));

	if FileSystem.FileExists( xefubackup_folder .. "xefu2021.xex" ) and FileSystem.FileExists( xefubackup_folder .. "xefutitle2021.xex" ) then
		Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu2021.xex", "xefu2021.xex"));
	end

	if FileSystem.FileExists( xefubackup_folder .. "xefu2019.xex" ) and FileSystem.FileExists( xefubackup_folder .. "xefutitle2019.xex" ) then
		Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu2019.xex", "xefu2019.xex"));
	end

	Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu7b.xex", "xefu7b.xex"));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu7.xex", "xefu7.xex"));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu6.xex", "xefu6.xex"));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu1_1.xex", "xefu1_1.xex"));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu5.xex", "xefu5.xex"));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu3.xex", "xefu3.xex"));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu2.xex", "xefu2.xex"));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("xefu.xex", "xefu.xex"));
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
		if Menu.IsMainMenu(menu) then
			Script.SetStatus("Loading xefu options...");
			Script.SetProgress(25);
			
			if (ret == "RESET") then
				-- Set xefu files to default
				Script.SetStatus("Removing old xefu files...");
				Script.SetProgress(50);
				delete_xefu_files(compatibility_folder);
				Script.SetStatus("Resetting xefu files...");
				Script.SetProgress(75);
				copy_xefu_files(xefubackup_folder, compatibility_folder);
				FileSystem.DeleteFile(compatibility_folder .. "xefu_spoofer.txt");
				Script.ShowNotification("Xefu files reset to default behavior");
			else
				-- Spoof xefu file to selected option
				Script.SetStatus("Removing old xefu files...");
				Script.SetProgress(50);
				delete_xefu_files(compatibility_folder);
				Script.SetStatus("Spoofing xefu...");
				Script.SetProgress(75);
				spoof_xefu_files(ret);
				set_xefuspoofer_txt(ret);
				Script.ShowNotification("Xefu files spoofed to " .. ret);
			end
			Script.SetProgress(100);
		else
			Script.ShowMessageBox("ERROR", "An unknown error occurred!\n\nExiting...", "OK");
		end
	end
end
