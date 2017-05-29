scriptTitle = "Unity LiNK Info";
scriptAuthor = "saywaking";
scriptVersion = 1;
scriptDescription = "Get LiNK Info straight from Unity";
scriptIcon = "icon\\icon.xur";
scriptPermissions = { "http"};

require("AuroraUI");
local menu = require("MenuSystem");
local json = require("json");

function main()
  if isInitSuccessful() then
    Script.SetStatus( "Retrieving LiNK Title List...");
    Script.SetProgress( 30 );
    
    local linkTitleListTable = nil;
    local linkTitleListUrl = "http://xboxunity.net/Resources/Lib/TitleList.php?&search=&count=-1&sort=4&direction=1&category=3";
    local httpData = Http.Get(linkTitleListUrl);
    
    if httpData.OutputData ~= nil then
      linkTitleListTable = json:decode(httpData.OutputData);
    end
    
    if linkTitleListTable ~= nil then
      Script.SetStatus( "Reading LiNK Title List data...");
      
      Script.SetStatus( "Creating Menu...");
      Script.SetProgress( 50 );
      
      makeMenu(linkTitleListTable);
      
      Script.SetStatus( "Done ...");
      Script.SetProgress( 100 );
      
      showMenu();
    else
      Script.ShowMessageBox("Info", "LiNK Title List has no content. \nTry again later!", "Close");
    end
  end
  
    Script.SetStatus( "Done ...");
    Script.SetProgress( 100 );
end

function isInitSuccessful()
  local initSuccess = true;
  
  Script.SetStatus( "Initialising Script...");

  Script.SetStatus( "Checking JSON Helper...");
  if json ~= nil then
    Script.SetStatus( "JSON Helper passed...");
  else
    Script.SetStatus( "JSON Helper failed...");
    initSuccess = false;
  end

  Script.SetStatus( "Checking Internet Connection...");
  Script.SetProgress( 25 );
  
  if Aurora.HasInternetConnection() then
    Script.SetStatus( "Internet Connection passed...");
  else
    Script.SetStatus( "Internet Connection failed...");
    initSuccess = false;
  end
  
  return initSuccess;
end

function getMenuItemModifiedLength(menuItemString)
  local newString = menuItemString;
  local maxLength = 70;
  local reservedCharacterCount = 25;
  
  
  if string.len(newString) > (maxLength - reservedCharacterCount) then
    newString = string.sub(newString, (maxLength - reservedCharacterCount));
  else
    local fillLength = maxLength - reservedCharacterCount - string.len(newString);
    for i=1,fillLength do
      newString = newString .. " ";
    end
  end
  
  return newString;
end

function makeMenu(linkTitleListTable)
  Menu.ResetMenu();
	Menu.SetTitle(scriptTitle);
	Menu.SetGoBackText("");
  Menu.SetSortAlphaBetically(false);
  
  for i, title in pairs(linkTitleListTable.Items) do
    local menuItemName = title.Name .. " ............................. " .. title.UserCount .. " User";
    local titleMenuItem = Menu.MakeMenuItem(menuItemName, title);
    
    local progressNumber = getProgressForMakeMenu(i, linkTitleListTable.Count, 50)
    Script.SetProgress( progressNumber );
    
    if tonumber(title.UserCount) > 0 then
      Script.SetStatus( "Scanning " .. title.Name );
      
      local maxScanAttempts = 10;
      local scanAttempt = 0;
      local roomListTable = getRoomListTable(title.TitleID);
      
      while (roomListTable == nil) and (scanAttempt <= maxScanAttempts) do
        Script.SetStatus( "Error while scanning: " .. title.Name );
        Script.SetStatus( "Trying scan again: " .. title.Name );
        roomListTable = getRoomListTable(title.TitleID);
        
        scanAttempt = scanAttempt + 1;
      end
      
      if roomListTable ~= nil then
        -- Add Rooms to Title Menu Item
        for i, room in pairs(roomListTable) do
          local roomMenuItem = Menu.MakeMenuItem(room.RoomName .. " ............................. " .. room.TotalUsers .. " User", room);
          
          -- Add User to Room Menu Item
          for i, user in pairs(room.Users) do
            local userMenuItem = Menu.MakeMenuItem(user.Username, user);
            
            Menu.AddSubMenuItem(roomMenuItem, userMenuItem);
          end
          
          Menu.AddSubMenuItem(titleMenuItem, roomMenuItem);
        end
      else
        Script.SetStatus( "Error while scanning: " .. title.Name );
      end
    else
      Script.SetStatus( "Skipping: " .. title.Name );
    end
    
    Menu.AddMainMenuItem(titleMenuItem);
  end
end

function showMenu()
  local selectedMenuItem = {}
	local canceled = false;
	selectedMenuItem, _, canceled, menuItem = Menu.ShowMainMenu();
  
	if not canceled then
    handleItem(selectedMenuItem);
    showMenu();
  end
end

function handleItem(menuItem)

  if isEmptyTitleMenuItem(menuItem) then
    showInfo(menuItem, "Title Information");
  elseif isEmptyRoomMenuItem(menuItem) then
    showInfo(menuItem, "Room Information");
  elseif isUserMenuItem(menuItem) then
    showInfo(menuItem, "User Information");
  end
end

function getRoomListTable(titleID)
  local roomListUrl = "http://xboxunity.net/Resources/Lib/LinkInfo.php?titleid=" .. titleID;
  local httpData = Http.Get(roomListUrl);
  
  if httpData.Success then 
    return json:decode(httpData.OutputData).Rooms;
  end
  
  return nil;
end

function showInfo(menuItem, messageBoxTitle)
  local info = "";
  
  for key, value in pairs(menuItem) do
    if (value ~= nil) and ((type(value) == "string" or type(value) == "number")) then
      info = info .. key .. ":   " .. value .. "\n";
    end
  end
  
	Script.ShowMessageBox(messageBoxTitle, info, "OK");
end

function isEmptyTitleMenuItem(menuItem)
  if (menuItem.UserCount ~= nil) and (tonumber(menuItem.UserCount) < 1) then
    return true
  end
    
  return false;
end

function isEmptyRoomMenuItem(menuItem)
  if (menuItem.TotalUsers ~= nil) and (tonumber(menuItem.TotalUsers) < 1) then
    return true
  end
    
  return false;
end

function isUserMenuItem(menuItem)
  if menuItem.Username ~= nil then
    return true
  end
    
  return false;
end

function getProgressForMakeMenu(number, absolute, range)
  local prozent = ((number+1)/absolute) * range;
  
  return (range + math.floor(prozent));
end
