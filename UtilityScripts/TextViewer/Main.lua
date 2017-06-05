scriptTitle = "Text Viewer";
scriptAuthor = "saywaking";
scriptVersion = 1;
scriptDescription = "Read a plain Text File";
scriptIcon = "icon\\icon.png";
scriptPermissions = { "filesystem" };

require("AuroraUI");
local menu = require("MenuSystem");
local gizmo = require("gizmo");

local selectedFile = {};
local currentItem = {};
local supportedFileEndings = {"txt", "ini", "md", "meta", "json", "log", "list", "lua", "js", "html", "xml"};

function main()  
  Script.SetStatus( "Initializing script...");
  initializeRootDirectory();
  
  makeMenu();
  showMenu();

  Script.SetProgress( 100 );
end

function initializeRootDirectory()
  Script.SetStatus( "Initializing Root Directory...");
  
  local drives =  FileSystem.GetDrives(true);

  currentItem = {};
  currentItem["name"]  = "Root";
  currentItem["path"]  = "\\";
  currentItem["mountPoint"]  = "\\";
  currentItem["type"] = "root";
  currentItem["upperDirPath"] = nil;
  currentItem["items"] = {};
  
  for i, device in pairs(drives) do
    currentItem["items"][i] = {};
    currentItem["items"][i]["name"] = device.Name;
    currentItem["items"][i]["mountPoint"] = device.MountPoint;
    currentItem["items"][i]["path"] = device.MountPoint;
    currentItem["items"][i]["type"] = "device";
    currentItem["items"][i]["upperDirPath"] = currentItem["path"];
  end
end

function makeMenu()
  Script.SetStatus( "Making Menu...");
  Script.SetProgress( 99 );

  Menu.ResetMenu();
  Menu.SetTitle(scriptTitle .. "  |  " .. currentItem.path);
  Menu.SetGoBackText("");
  Menu.SetSortAlphaBetically(false);
  
  for i, item in pairs(currentItem.items) do
    local menuItemName = item.name;
    local menuItem = Menu.MakeMenuItem(menuItemName, item);
      
    Menu.AddMainMenuItem(menuItem);
  end
end

function showMenu()
  local selectedMenuItem = {};
  local canceled = false;
  selectedMenuItem, _, canceled, menuItem = Menu.ShowMainMenu();
  
  if not canceled then
    handleItem(selectedMenuItem);
    makeMenu();
    showMenu();
  else
    handleBack();
  end
end

function handleItem(menuItem)
  if isRootItem(menuItem) then
    --
  elseif isDeviceItem(menuItem) then
    currentItem = {};
    currentItem["name"]  = menuItem.name;
    currentItem["path"]  = menuItem.mountPoint;
    currentItem["mountPoint"]  = menuItem.mountPoint;
    currentItem["type"] = "device";
    currentItem["upperDirPath"] = menuItem.upperDirPath;
    currentItem["items"] = {};
    
    local filesAndDirectories = FileSystem.GetFilesAndDirectories(menuItem.mountPoint .. "\\*");
    for i, item in pairs(filesAndDirectories) do
      currentItem["items"][i] = {};
      currentItem["items"][i]["name"] = item.Name;
      currentItem["items"][i]["path"] = menuItem.mountPoint .. "\\" .. item.Name;
      currentItem["items"][i]["mountPoint"] = menuItem.mountPoint;
      currentItem["items"][i]["type"] = getType(item);
      currentItem["items"][i]["upperDirPath"] = currentItem["path"];
    end
  elseif isDirectoryItem(menuItem) then
    currentItem = {};
    currentItem["name"]  = menuItem.name;
    currentItem["path"]  = menuItem.path;
    currentItem["mountPoint"]  = menuItem.mountPoint;
    currentItem["type"] = menuItem.type;
    currentItem["upperDirPath"] = menuItem.upperDirPath;
    currentItem["items"] = {};
    
    local filesAndDirectories = FileSystem.GetFilesAndDirectories(menuItem.path .. "\\*");
    for i, item in pairs(filesAndDirectories) do
      currentItem["items"][i] = {};
      currentItem["items"][i]["name"] = item.Name;
      currentItem["items"][i]["path"] = menuItem.path .. "\\" .. item.Name;
      currentItem["items"][i]["mountPoint"] = menuItem.mountPoint;
      currentItem["items"][i]["type"] = getType(item);
      currentItem["items"][i]["upperDirPath"] = currentItem["path"];
    end
  elseif isFileItem(menuItem) then
    Script.SetStatus( "Displaying Text...");
    
    local file = {};
    file["name"] = menuItem.name
    file["path"] = menuItem.path
    file["text"] = FileSystem.ReadFile(menuItem.path);
    
    if isFileSupported(file["path"]) then
      gizmo.run(file);
    else
      local message = "Only the following Filetypes are supported: \n\n";
      for i, fileEnding in pairs(supportedFileEndings) do
        message = message .. "-" .. fileEnding .. "-";
      end
      Script.ShowMessageBox("Info", message, "Close");
    end
  end
end

function handleBack()
  if isRootItem(currentItem) then
    -- exit
  elseif isDeviceItem(currentItem) then
    initializeRootDirectory();
    makeMenu();
    showMenu();
  elseif isDirectoryItem(currentItem) then
    local newItem = createItemFromCurrentUpperDirPath();
    
    currentItem = {};
    currentItem = newItem;
    
    makeMenu();    
    showMenu();
  elseif isFileItem(currentItem) then
    -- display Current Item again, won't ever come here yet.
  end
end

function isRootItem(item)
  if item.type == "root" then
    return true;
  end
  return false;
end

function isDeviceItem(item)
  if item.type == "device" then
    return true;
  end
  return false;
end

function isDirectoryItem(item)
  if item.type == "directory" then
    return true;
  end
  return false;
end

function isFileItem(item)
  if item.type == "file" then
    return true;
  end
  return false;
end

function getType(item)
  if item.Attributes == 16 then
    return "directory"
  elseif item.Attributes == 128 then
    return "file"
  else
    return item.Attributes
  end
end

function createItemFromCurrentUpperDirPath()
  local newItem = {};
  
  newItem["path"]  = currentItem["upperDirPath"];
  
  if currentItem["upperDirPath"]:find("\\") == nil then
    -- Path contains no slash, so the item must be a device.
    newItem["name"] = currentItem["upperDirPath"];
    newItem["mountPoint"]  = currentItem["upperDirPath"]:sub(0, 
                                                           currentItem["upperDirPath"]:find(":\\"));
    newItem["upperDirPath"] = "\\";
    
  else
    newItem["name"]  = currentItem["upperDirPath"]:sub((currentItem["upperDirPath"]:find("\\[^\\]*$")+1), 
                                                        currentItem["upperDirPath"]:len());
    newItem["mountPoint"]  = currentItem["upperDirPath"]:sub(0, 
                                                             currentItem["upperDirPath"]:find(":\\"));
    newItem["upperDirPath"] = currentItem["upperDirPath"]:sub(0, 
                                                              (currentItem["upperDirPath"]:find("\\" .. newItem["name"])-1));
  end
  
  newItem["type"] = getMenuTypeByNameAnalysis(newItem["name"]);
  newItem["items"] = {};  
  
  local filesAndDirectories = FileSystem.GetFilesAndDirectories(newItem.path .. "\\*");
  for i, item in pairs(filesAndDirectories) do
    newItem["items"][i] = {};
    newItem["items"][i]["name"] = item.Name;
    newItem["items"][i]["path"] = newItem.path .. "\\" .. item.Name;
    newItem["items"][i]["mountPoint"] = newItem.mountPoint;
    newItem["items"][i]["type"] = getType(item);
    newItem["items"][i]["upperDirPath"] = newItem["path"];
  end
  
  return newItem;
end

function getMenuTypeByNameAnalysis(name)
  local drives =  FileSystem.GetDrives(true);
  
  for i, device in pairs(drives) do
    if name == device.MountPoint then
      return "device"
    end
  end
  
  return "directory";
end

function isFileSupported(path)
  for i, fileEnding in pairs(supportedFileEndings) do
    if path:find(fileEnding) ~= nil then
      return true;
    end
  end
  
  return false;
end