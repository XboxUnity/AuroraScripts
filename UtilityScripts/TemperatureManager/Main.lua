scriptTitle = "Temperature Manager"
scriptAuthor = "saywaking"
scriptVersion = 1
scriptDescription = "This script displays and manages your fan speed and target temperatures."
scriptPermissions = { "kernel" }
scriptIcon = "skin\\icon.png";

require("AuroraUI");  
gizmo = require("Gizmo");

currentTemperatureSettings = {};

local disclaimerMessage = "Warning \n\n" ..
                          "You are fully responsible for the changes on your temperature/fan settings.\n" ..
                          "Bad Settings may lead your console to 'death'.\n";

function main()
  Script.SetStatus("Displaying Disclaimer");
  Script.SetProgress(15);
  
  local selection = Script.ShowMessageBox("Disclaimer", disclaimerMessage, "Accept", "Close");
  if selection.Button == 1 then
    Script.SetStatus("Retrieving current Temperature Settings");
    Script.SetProgress(50);
    currentTemperatureSettings = getCurrentTemperatureSettings();

    Script.SetStatus("Displaying Temperature Manager");
    Script.SetProgress(99);
    gizmo.run();
  end
  
  Script.SetStatus("Ended");
  Script.SetProgress(100);
end


function getCurrentTemperatureSettings()
  -- TODO: iniFile

  return 
  {
    ["currentCPUThreshold"] = Kernel.GetCPUTempThreshold(),
    ["currentGPUThreshold"] = Kernel.GetGPUTempThreshold(),
    ["currentRAMThreshold"] = Kernel.GetEDRAMTempThreshold(),
    ["currentFanSpeed"] = 30 -- default
  };
end

