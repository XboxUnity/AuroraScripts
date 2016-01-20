scriptTitle = "Aurora Database Cleaner"
scriptAuthor = "Phoenix"
scriptVersion = 0.1
scriptDescription = "A database cleaner for Aurora (Removes database entries for titles which no longer exists)"
scriptIcon = "icon.png"

-- Define script permissions to enable access to libraries
scriptPermissions = { "sql", "filesystem" }  

-- Main entry point to script
function main()
	Script.SetStatus("Gathering content info from Database...");
	local notMountedCounter = 0; -- Used to determine if there was devices that wasn't mounted
	local cleanedCounter = 0; -- Used to determine if any database changes were made requiring a reload of Aurora
	local contentCounter = 0; -- Used to determine how far we've processed
	local dirCounter = 0; -- Used to keep track of current index for dirInfo
	local dirInfo = {} -- Used to store the directory information for each scanpath
	for _, v in pairs(Sql.ExecuteFetchRows("SELECT Id,Path,DeviceId FROM ScanPaths")) do
		local c, mountpoint, cnt = GetContentItemsForScanPath(v.Id, v.DeviceId);
		if mountpoint == nil then
			notMountedCounter = notMountedCounter + 1;
		else
			dirCounter = dirCounter + 1;
			dirInfo[dirCounter] = {}
			dirInfo[dirCounter].Dir = mountpoint .. v.Path;
			dirInfo[dirCounter].Content = c;
			dirInfo[dirCounter].Count = cnt;
			contentCounter = contentCounter + cnt;
		end
	end
	local progressCounter = 0;
	local cnt = 0;
	for _, v in pairs(dirInfo) do
		cnt, progressCounter = CleanupContent(v.Content, v.Dir, progressCounter, contentCounter);
		cleanedCounter = cleanedCounter + cnt;
	end
	if notMountedCounter > 0 then
		Script.ShowMessageBox("Unmounted devices detected...", "There was scanpaths which could not be checked\n\nYour options for these devices are:\n\n1. Attach it and run the script again\n2. Remove the scanpath", "OK");
	end
	Script.SetStatus("Cleanup finished...");
	Script.ShowNotification(string.format("%d Titles effected by the script", cleanedCounter));
	if cleanedCounter > 0 then
		local ret = Script.ShowMessageBox("Reload Required", "In order for the changes to take effect you need to reload Aurora\nDo you want to reload Aurora now?", "No", "Yes");
		if ret.Button == 2 then
			Aurora.Restart();
		end
	end
end

--GetContentItemsForScanPath function, it gets the mountpoint of the scanpath and all related content
--Expected Input:
--				  pathid: Database Id for the scanpath
--				  deviceid: Device ID for the mountpoint
--Returns: ContentList, MountPoint, Count of content items
--Returns: nil, nil 0 if there is no mountpoint to be found for the Device ID
function GetContentItemsForScanPath(pathid, deviceid)
	local mountpoint = nil;
	if deviceid ~= nil then
		for _, v in pairs(Sql.ExecuteFetchRows("SELECT MountPoint FROM MountedDevices WHERE DeviceId == \"" .. deviceid .. "\"")) do
			mountpoint = v.MountPoint;
			break; -- We only want the first entry, should only return one value tho...
		end
		if mountpoint ~= nil then
			local content = Sql.ExecuteFetchRows("SELECT Id,Directory,Executable,TitleId,TitleName FROM ContentItems WHERE ScanPathId == " .. pathid);
			local cnt = 0;
			for k in pairs(content) do
				content[k].Directory = mountpoint .. content[k].Directory;
				cnt = cnt + 1;
			end
			return content, mountpoint, cnt;
		end
	end
	return nil, nil, 0;
end

--CleanupContent function, it checks if the title exists, if not it'll cleanup everything related to it
-- Expected input: 
--				   list: a table containing: Id,Directory,Executable,TitleId and TitleName where Directory has been corrected to have the mountpoint 
--				   dir: MountPoint + Path of the scanpath (to display to the user)
--				   progressCounter: Current progress, 0 if first otherwise whatever was returned before
--				   total: Total ammount of items
--Returns: CountOfRemovedEntries, progressCounter incremented by items processed
function CleanupContent(list, dir, progressCounter, total)
	local cnt = 0;
	for _, v in pairs(list) do
		Script.SetStatus("Processing " .. dir);
		if (not FileSystem.FileExists(v.Directory .. "\\" .. v.Executable)) then
			cnt = cnt + 1;
			Cleanup(v);
		end
		progressCounter = progressCounter + 1;
		Script.SetProgress(progressCounter, total);
	end
	return cnt, progressCounter;
end

-- Cleanup function, it deletes the assets and removes the title from the database
-- Expected input: a table containing TitleName, TitleId and Database Id
function Cleanup(v)
	Script.SetStatus("Cleaning up assets for ".. v.TitleName);
	FileSystem.DeleteDirectory(string.format("game:\\Data\\GameData\\%08X_%08X", tounsigned(v.TitleId), tounsigned(v.Id)));
	Script.SetStatus("Removing Title from DB: ".. v.TitleName);
	Sql.Execute("DELETE FROM ContentItems WHERE Id == " .. v.Id);
end