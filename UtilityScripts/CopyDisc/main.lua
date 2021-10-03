scriptTitle = "Simple Game Disc to HDD Copy"
scriptAuthor = "TheNicNic"
scriptVersion = 1
scriptDescription = "Copy Disc Files To Directory"
scriptIcon = "icon.png"

-- Define script permissions to enable access to libraries
scriptPermissions = { "filesystem", "content" }  

-- Define used enums
FilebrowserFlag = enum {
    ShowFiles           = 0x01,
    BaseDirAsRoot       = 0x02,
    HideCreateDir       = 0x04,
    DisableHomeDrives   = 0x08,
    DeviceSelect        = 0x10,
    SelectDirectory     = 0x20
}

NotificationType = enum {
    Information         = 0,
    System              = 1,
    Warning             = 2,
    Error               = 3,
    XAM                 = 4
}

-- Global variables
glTotalSize = 0;
glCopyProgress = 0;
glSizeDiff = 0;
glExitCode = 2;

-- Main entry point to script
function main()
    Script.SetCancelEnable(true);
   
    local ret;
    local targetPath = "";
    local createContentDirs = false;
    local originPath = "Dvd:";
    local dirCreated = false;
    
    Script.SetStatus("Select destination directory");
    
    if Aurora.GetDVDTrayState() ~= 2 then -- Abort if tray isn't closed
      glExitCode = 1;
      Aurora.CloseDVDTray();
      goto ExitScript;
    end
    
    discContent = FileSystem.GetFilesAndDirectories(originPath .. "\\*");
    
    -- Browse for destination path
    ret = Script.ShowFilebrowser("\\Xbox360\\System\\", "", FilebrowserFlag.BaseDirAsRoot + FilebrowserFlag.SelectDirectory);
    
    -- Check if canceled
    if ret.Canceled == true then
      glExitCode = 2;
      goto ExitScript;
    else
      -- Get installation path
      local selectedDir = ret.File;
      
      -- Synthesize real root from VirtualRoot string
      local root = selectedDir.VirtualRoot;
      root = root:gsub("\\Xbox360\\System\\", "");
      root = root:gsub("\\", "") .. ":";
      
      targetPath = root .. "\\" .. selectedDir.RelativePath .. "\\" .. selectedDir.Name .. "\\";
      
      if FileSystem.FileExists("Dvd:\\default.xbe") then -- Xbox (OG) game detected
        -- Suggest iterating directory name
        existingDirs = FileSystem.GetDirectories(targetPath .. "\\*");
        suggestDirName(existingDirs, "XBOX_GA", 0);
        ret = Script.ShowKeyboard(scriptTitle, "Please enter a name for the game directory", suggestedName, 0);
        dirName = ret.Buffer;
      elseif FileSystem.FileExists("Dvd:\\default.xex") then -- Xbox 360 game detected
        -- Suggest iterating directory name
        existingDirs = FileSystem.GetDirectories(targetPath .. "\\*");
        suggestDirName(existingDirs, "X360_GA", 0);
        ret = Script.ShowKeyboard(scriptTitle, "Please enter a name for the game's directory", suggestedName, 0);
        dirName = ret.Buffer;
      end
      
      if(dirName == nil) then
        glExitCode = 2;
        goto ExitScript;
      end
      
      targetPath = targetPath .. tostring(dirName) .. "\\"; -- Create final directory path
      ret = Script.ShowMessageBox(scriptTitle, "Game will be copied to: \n" .. targetPath, "OK", "Cancel");
      if ret.Button == 2 then
        goto ExitScript;
      end
      FileSystem.CreateDirectory(targetPath);
      dirCreated = true;
    end
        
    Script.SetStatus("Copy to " .. targetPath);
      
    -- Total files size count
    for i, item in pairs(discContent) do
      if item.Attributes == 1 then --file
        glTotalSize = glTotalSize + (todouble(item.Size))
      elseif item.Attributes == 17 then --directory
        countHelper("\\" .. item.Name .. "\\", "");
      end
    end
    
    glExitCode = 0; -- Flag for successful ending
    
    -- Actual copy
    if Aurora.GetDVDTrayState() ~= 2 then -- Check again for closed tray
      glExitCode = 1;
      Aurora.CloseDVDTray();
      goto ExitScript;
    end
    for i, item in pairs(discContent) do
      if item.Attributes == 1 then --file
        Script.SetStatus(item.Name .. " [file] ")
        glSizeDiff = 0 --Resets the difference to previous file size for continuous progress bar
        FileSystem.CopyFile("Dvd:\\" .. item.Name, targetPath .. item.Name, true, progressRoutine)
      elseif item.Attributes == 17 then --directory
        Script.SetStatus(item.Name .. " [directory] ")
        glSizeDiff = 0 --Resets the difference to previous file size for continuous progress bar
        FileSystem.CopyDirectory("Dvd:\\" .. item.Name, targetPath .. item.Name, true, progressRoutine)
      end
    end
    
    Aurora.OpenDVDTray(); -- Cause you don't need it anymore after successful read
   
    ::ExitScript:: -- Exit handling
    if glExitCode == 0 then
      Script.ShowNotification("Copy completed", NotificationType.Information);
      ret = Script.ShowMessageBox("Scan for content", "Scan for new content now?\n\nThis will add the installed title if it is installed in a scan path location.", "Yes", "No");
      if ret.Button == 1 then
        if Content.StartScan() == true then
          Script.ShowNotification("Content Scan started");
        else
          Script.ShowNotification("Unable to start Content Scan", NotificationType.Warning);
        end
      end
    elseif glExitCode == 1 then
      Script.ShowNotification("Tray was open, please insert a Xbox or Xbox 360 game disc and run again", NotificationType.Warning);
    elseif glExitCode == 2 then
      if dirCreated == true then
        ret = Script.ShowMessageBox("Delete directory?", "Incomplete copy due user abortion.\nDo you want to cleanup the created directory?", "Yes", "No");
        if ret.Button == 1 then
          FileSystem.DeleteDirectory(targetPath);
          Script.SetStatus("Deleting: " .. targetPath);
        end
      Script.ShowNotification("Aborted by user", NotificationType.Warning);
      end
    end
end

function todouble(number) -- Enforce double instead of 32-bit in because of signed int max value limit
  if number == nil then
    return 0.0;
  else
    return number + 0.0;
  end
end

function round(number)
  return math.floor(number * 10 + 0.5) / 10;
end

function suggestDirName(existingDirs, platform, startNumber)
  suggestedName = tostring(platform .. startNumber);
  for i, item in pairs(existingDirs) do
    if item.Name == suggestedName then
      startNumber = startNumber + 1;
      suggestDirName(existingDirs, platform, startNumber);
    end
  end
  return suggestedName;
end

function progressRoutine(totalfilesize, filesize)
  if Script.IsCanceled() then
    glExitCode = 2;
    Aurora.OpenDVDTray(); -- This forces the "CopyFile" and "CopyDirectory" operations to abort
  end
          
  glCopyProgress = glCopyProgress + (todouble(filesize) - glSizeDiff);
  glSizeDiff = (todouble(filesize));
  Script.SetStatus(round(todouble(glCopyProgress)/1024/1024) .. " MB of " .. round(todouble(glTotalSize)/1024/1024) .. " MB");
  Script.SetProgress(glCopyProgress, glTotalSize);
end

function countHelper(dirName, prevDirs)
  local path = FileSystem.GetFilesAndDirectories("Dvd:" .. prevDirs .. dirName .. "*")
  prevDirs = prevDirs .. dirName;
  for i, item in pairs(path) do
  if item.Attributes == 1 then --file
    glTotalSize = glTotalSize + (todouble(item.Size));
  elseif item.Attributes == 17 then --directory  
    countHelper(item.Name .. "\\", prevDirs);
  end
end

end
