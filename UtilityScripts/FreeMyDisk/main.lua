scriptTitle = "Free My Disk"
scriptAuthor = "Dan Martí"
scriptVersion = 1
scriptDescription = "Free your HDD from title updates of games that you don't have anymore!\nfb.com/Danotopia"
scriptIcon = "icon.png";

scriptPermissions = { "filesystem", "sql" }


local function roundToNthDecimal(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Main entry point to script
function main()
	print("-- " .. scriptTitle .. " Started...");
	-- init();
	Script.SetStatus("Scanning DB and files...");
	Script.SetProgress(0);
	local sqlquery="SELECT Id as id, tus.DisplayName AS tu, tus.BackupPath AS backuppath, (tus.LivePath || tus.FileName) AS path FROM TitleUpdates AS tus WHERE tus.TitleId NOT IN (SELECT TitleId FROM ContentItems WHERE TitleId=tus.TitleId) AND NOT tus.MediaId=0";
	local size=0;
	local thissize;
	local tuid = {};
	local filelist = {};
	local filetitles = "";
	local titlecount = 0;
	local filecount = 0;
	
	for _, v in pairs(Sql.ExecuteFetchRows(sqlquery)) do
		local path="Hdd1:" .. v.path;
		thissize=0;
		if FileSystem.FileExists(v.backuppath) then
			filecount = filecount + 1;
			thissize = thissize + ((FileSystem.GetFileSize(v.backuppath)/1024)/1024);
			filelist[filecount] = v.backuppath;
		end
		if FileSystem.FileExists(path) then
			filecount = filecount + 1;
			thissize = thissize + ((FileSystem.GetFileSize(path)/1024)/1024);
			filelist[filecount] = path;
		end
		if thissize>0 then
			titlecount=titlecount+1;
			tuid[titlecount]=v.id;
			filetitles=filetitles .. "\n" .. string.sub(v.tu,1,20) .. "... (" .. roundToNthDecimal(thissize,1) .. "Mb)";
		end
		size = size + thissize;
	end
	if size==0 then
		Script.ShowMessageBox(scriptTitle, "Good news!\nThere are no Title Updates unused so nothing to do here", "OK");
		return true;
	end
	::promptagain::
	local sel = Script.ShowMessageBox(scriptTitle, "There were " .. titlecount .. " unnecesary TUs (" .. roundToNthDecimal(size,1) .. "Mb)" .. filetitles .. "\n" .. roundToNthDecimal(size,1) .. "Mb in total.\nDo you want to remove them?", "Yes", "No");
	if sel.Button==1 then
		local sel2 = Script.ShowMessageBox(scriptTitle, "The files are gonna be deleted permanently\nAre you sure you want to do this?", "Yes", "No");
		if sel2.Button==1 then
			local counter = 1;
			local err=0;
			local freedsize=0;
			for _, v in pairs(filelist) do
				Script.SetStatus("Deleting " .. counter .. " of " .. filecount .. "...");
				Script.SetProgress(roundToNthDecimal((counter*100)/filecount,0));
				local sz=FileSystem.GetFileSize(v);
				if FileSystem.DeleteFile(v) ~= true then
					print("Error: Failed deleting " .. v);
					err = err + 1;
				else
					freedsize = freedsize + sz;
				end
				counter = counter + 1;
			end
			counter=1;
			for _, v in pairs(tuid) do
				Script.SetStatus("Cleaning DB " .. counter .. " of " .. titlecount .. "...");
				Script.SetProgress(roundToNthDecimal(counter*100)/titlecount,0);
				if Sql.Execute("DELETE FROM TitleUpdates WHERE Id=" .. v) ~= true then
					print("Error: Failed remove from TitleUpdates with Id=" .. v);
					err = err + 1;
				end
				counter = counter + 1;
			end
			Script.SetStatus("Done!");
			if err==0 then
				Script.ShowMessageBox(scriptTitle,"Done!\n" .. ((freedsize/1024)/1024) .. "Mb deleted in " .. filecount .. " files of " .. titlecount .. " TUs");
			else
				Script.ShowMessageBox(scriptTitle,"Done!\n" .. ((freedsize/1024)/1024) .. "Mb deleted in " .. filecount .. " files of " .. titlecount .. " TUs\nBut...\nThere were " .. err .. " errors. Check the log file");
			end
		else
			goto promptagain;
		end
	end
	print("-- " .. scriptTitle .. " Ended...");
end
