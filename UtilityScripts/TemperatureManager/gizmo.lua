local Gizmo = {};         -- public namespace
local GP = {};            -- private namespace
local Xui = {};

function Gizmo.run( scriptData )
  local hGizmo = GizmoUI.CreateInstance();
  if hGizmo ~= nil then  
    hGizmo:RegisterCallback( XuiMessage.Init, GP.fnOnInit ); 
    hGizmo:RegisterCallback( XuiMessage.Command, GP.fnOnCommand );    
    hGizmo:RegisterCallback( XuiMessage.Timer, GP.fnOnTimer );
    
    return hGizmo:InvokeUI(Script.GetBasePath(), "Temperature Manager", "skin\\scene.xur", "skin\\skin.xur", scriptData );
  end
end

function GP.fnOnInit( this, initData )
  Xui["cpuValue"] = this:RegisterControl( XuiObject.Label, "cpuValueLabel" );
  Xui["gpuValue"] = this:RegisterControl( XuiObject.Label, "gpuValueLabel" );
  Xui["ramValue"] = this:RegisterControl( XuiObject.Label, "ramValueLabel" );
  Xui["caseValue"] = this:RegisterControl( XuiObject.Label, "caseValueLabel" );
  Xui["fanValue"] = this:RegisterControl( XuiObject.Label, "fanValueLabel" );
  Xui["cpuSliderValue"] = this:RegisterControl( XuiObject.Slider, "cpuValueSlider" );
  Xui["gpuSliderValue"] = this:RegisterControl( XuiObject.Slider, "gpuValueSlider" );
  Xui["ramSliderValue"] = this:RegisterControl( XuiObject.Slider, "ramValueSlider" );
  Xui["fanSliderValue"] = this:RegisterControl( XuiObject.Slider, "fanValueSlider" );
  
  Xui.cpuSliderValue:SetValue(currentTemperatureSettings["currentCPUThreshold"]);
  Xui.gpuSliderValue:SetValue(currentTemperatureSettings["currentGPUThreshold"]);
  Xui.ramSliderValue:SetValue(currentTemperatureSettings["currentRAMThreshold"]);
  Xui.fanSliderValue:SetValue(currentTemperatureSettings["currentFanSpeed"]);
  
  this:SetCommandEnabled( GizmoCommand.A, true ); 
  this:SetCommandText( GizmoCommand.A, "Target Temps" );
  this:SetCommandEnabled( GizmoCommand.Y, true ); 
  this:SetCommandText( GizmoCommand.Y, "Fan Speed" );
  
  this:SetTimer(1, 1000);
end

function GP.fnOnCommand( this, commandType )
  local newCPUThreshold = Xui.cpuSliderValue:GetValue();
  local newGPUThreshold = Xui.gpuSliderValue:GetValue();
  local newRAMThreshold = Xui.ramSliderValue:GetValue();
  local newFanSpeed = Xui.fanSliderValue:GetValue();
  
  if commandType == GizmoCommand.A then
    if newCPUThreshold ~= currentTemperatureSettings["currentCPUThreshold"] or
       newGPUThreshold ~= currentTemperatureSettings["currentGPUThreshold"] or
       newRAMThreshold ~= currentTemperatureSettings["currentRAMThreshold"]
    then
      currentTemperatureSettings["currentCPUThreshold"] = newCPUThreshold;
      currentTemperatureSettings["currentGPUThreshold"] = newGPUThreshold;
      currentTemperatureSettings["currentRAMThreshold"] = newRAMThreshold;
      
      Kernel.SetCPUTempThreshold(newCPUThreshold);
      Kernel.SetGPUTempThreshold(newGPUThreshold);
      Kernel.SetEDRAMTempThreshold(newRAMThreshold);
      Script.ShowNotification("Changes applied. Reboot Required");
    else
      Script.ShowNotification("No Changes found");
    end
  end
  
  if commandType == GizmoCommand.Y then
    
    if newFanSpeed ~= currentTemperatureSettings["currentFanSpeed"]
    then
      currentTemperatureSettings["currentFanSpeed"] = newFanSpeed;
      
      Kernel.SetFanSpeed(newFanSpeed);
      
      Xui.fanValue:SetText(newFanSpeed .. " %");
      Script.ShowNotification("Changes applied");
    else
      Script.ShowNotification("No Changes found");
    end
  end
end 

function GP.fnOnTimer( this, timerId )
  Xui.cpuValue:SetText( (string.format("%.2f", Aurora.GetTemperatures().CPU) .."°C") );
  Xui.gpuValue:SetText( (string.format("%.2f", Aurora.GetTemperatures().GPU) .."°C") );
  Xui.ramValue:SetText( (string.format("%.2f", Aurora.GetTemperatures().RAM) .."°C") );
  Xui.caseValue:SetText( (string.format("%.2f", Aurora.GetTemperatures().BRD) .."°C") );
end 

return Gizmo;