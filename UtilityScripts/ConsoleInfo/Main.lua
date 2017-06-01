scriptTitle = "Console Info Viewer"
scriptAuthor = "Phoenix"
scriptVersion = 2
scriptDescription = "This script displays valuable information about your console"
scriptPermissions = { "kernel" }
scriptCompatibility = { "0.6" }

function main()
  local message;
  
  if isDashboardCompatible() and hasPermissions() then
    message = getConsoleInfo();
  else
    message = "ERROR: Either Dashboard isn't compatible or there was a permission/API Error";
  end
  
  Script.ShowMessageBox("Console Information", message, "Close");
end

function getConsoleInfo()
  local kernelVersionTable = Kernel.GetVersion();
  local kernelVersion      = kernelVersionTable.Major .. "." .. 
                             kernelVersionTable.Minor .. "." .. 
                             kernelVersionTable.Build .. "." .. 
                             kernelVersionTable.Qfe;
  local consoleType        = Kernel.GetConsoleType();
  local motherboardType    = Kernel.GetMotherboardType();
  local consoleSerial      = Kernel.GetSerialNumber();
  local consoleId          = Kernel.GetConsoleId();
  local CPUkey             = Kernel.GetCPUKey() and Kernel.GetCPUKey() or "N\\A";
  local DVDkey             = Kernel.GetDVDKey() and Kernel.GetDVDKey() or "N\\A";
  
  return  "Kernel Version: "   .. kernelVersion   .. "\n" ..
          "Console Type: "     .. consoleType     .. "\n" ..
          "Motherboard Type: " .. motherboardType .. "\n" ..
          "Console Serial: "   .. consoleSerial   .. "\n" ..
          "Console ID: "       .. consoleId       .. "\n" ..
          "CPU Key: "          .. CPUkey          .. "\n" ..
          "DVD Key: "          .. DVDkey;
end

function isDashboardCompatible()
  local auroraVersionTable   = Aurora.GetDashVersion();
  local currentAuroraVersion = auroraVersionTable.Major .. "." ..
                               auroraVersionTable.Minor;
  
  if tableHasValue(scriptCompatibility, currentAuroraVersion) then
    return true;
  end
  
  return false;
end

function hasPermissions()
  local permission = true;
  
  for _, api in pairs(scriptPermissions) do
    if api == "kernel"     and Kernel == nil then
      permission = false;
    end
    
    if api == "http" and Http == nil then
      permission = false;
    end
    
    if api == "filesytem" and FileSystem == nil then
      permission = false;
    end
    
    if api == "content" and Settings == nil then
      permission = false;
    end
    
    if api == "sql" and Sql == nil then
      permission = false;
    end
    
    if api == "content" and content == nil then
      permission = false;
    end
    
    if not permission then
      print("ERROR: No " .. api .. " API permission allowed or accessible");
    end
  end
  
  return permission;
end

function tableHasValue (table, val)
  for index, value in pairs (table) do
    if value == val then
      return true
    end
  end
  
  return false
end
