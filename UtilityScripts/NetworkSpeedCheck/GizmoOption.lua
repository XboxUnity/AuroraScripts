local GizmoOption = {};         -- public namespace
local GP_Option = {};           -- private namespace
local Xui_Option = {};

function GizmoOption.run( scriptData )
  GizmoOption["options"] = scriptData;

  local hGizmo = GizmoUI.CreateInstance();
  
  if hGizmo ~= nil then  
    hGizmo:RegisterCallback( XuiMessage.Init, GP_Option.OnInit ); 
    hGizmo:RegisterCallback( XuiMessage.Command, GP_Option.OnCommand );
    
    return hGizmo:InvokeUI(Script.GetBasePath(), "Network Speed Check - Options", "skin\\options.xur", "skin\\skin.xur", GizmoOption["options"] );
  end
end

function GP_Option.OnInit( this, initData )
  Xui_Option["downloadTestEnabledCheck"] = this:RegisterControl( XuiObject.Checkbox, "downloadTestEnabledCheck" );
  Xui_Option["downloadCountSlider"] = this:RegisterControl( XuiObject.Slider, "downloadCountSlider" );
  Xui_Option["uploadTestEnabledCheck"] = this:RegisterControl( XuiObject.Checkbox, "uploadTestEnabledCheck" );
  Xui_Option["uploadCountSlider"] = this:RegisterControl( XuiObject.Slider, "uploadCountSlider" );
  Xui_Option["localIpTestEnabledCheck"] = this:RegisterControl( XuiObject.Checkbox, "localIpTestEnabledCheck" );
  Xui_Option["remoteIpTestEnabledCheck"] = this:RegisterControl( XuiObject.Checkbox, "remoteIpTestEnabledCheck" );
  Xui_Option["serverIpTestEnabledCheck"] = this:RegisterControl( XuiObject.Checkbox, "serverIpTestEnabledCheck" );
  Xui_Option["pingTestEnabledCheck"] = this:RegisterControl( XuiObject.Checkbox, "pingTestEnabledCheck" );
  
  -- init Default options
  if initData.downloadTest.enabled then
    Xui_Option.downloadTestEnabledCheck:SetCheck(true);
  end
  
  if initData.downloadTest.count ~= nil then
    Xui_Option.downloadCountSlider:SetValue(initData.downloadTest.count);
  end
  
  if initData.uploadTest.enabled then
    Xui_Option.uploadTestEnabledCheck:SetCheck(true);
  end
  
  if initData.uploadTest.count ~= nil then
    Xui_Option.uploadCountSlider:SetValue(initData.uploadTest.count);
  end
  
  if initData.additionalInfoTest.localIp then
    Xui_Option.localIpTestEnabledCheck:SetCheck(true);
  end
  
  if initData.additionalInfoTest.remoteIp then
    Xui_Option.remoteIpTestEnabledCheck:SetCheck(true);
  end
  
  if initData.additionalInfoTest.serverIp then
    Xui_Option.serverIpTestEnabledCheck:SetCheck(true);
  end
  
  if initData.pingJitterHopsTest then
    Xui_Option.pingTestEnabledCheck:SetCheck(true);
  end
  
  this:SetCommandEnabled( GizmoCommand.A, true );
  this:SetCommandEnabled( GizmoCommand.Y, true );
  this:SetCommandText( GizmoCommand.Y, "Continue" );
end

function GP_Option.OnCommand( this, commandType )
  if commandType == GizmoCommand.Y then
    -- save new options to the referenced options-table
    if Xui_Option.downloadTestEnabledCheck:IsChecked() then
      GizmoOption.options.downloadTest.enabled = true;
    else
      GizmoOption.options.downloadTest.enabled = false;
    end
    
    GizmoOption.options.downloadTest.count = Xui_Option.downloadCountSlider:GetValue();
    
    if Xui_Option.uploadTestEnabledCheck:IsChecked() then
      GizmoOption.options.uploadTest.enabled = true;
    else
      GizmoOption.options.uploadTest.enabled = false;
    end
    
    GizmoOption.options.uploadTest.count = Xui_Option.uploadCountSlider:GetValue();
    
    if Xui_Option.localIpTestEnabledCheck:IsChecked() then
      GizmoOption.options.additionalInfoTest.localIp = true;
    else
      GizmoOption.options.additionalInfoTest.localIp = false;
    end
    
    if Xui_Option.remoteIpTestEnabledCheck:IsChecked() then
      GizmoOption.options.additionalInfoTest.remoteIp = true;
    else
      GizmoOption.options.additionalInfoTest.remoteIp = false;
    end
    
    if Xui_Option.serverIpTestEnabledCheck:IsChecked() then
      GizmoOption.options.additionalInfoTest.serverIp = true;
    else
      GizmoOption.options.additionalInfoTest.serverIp = false;
    end
    
    if Xui_Option.pingTestEnabledCheck:IsChecked() then
      GizmoOption.options.pingJitterHopsTest = true;
    else
      GizmoOption.options.pingJitterHopsTest = false;
    end
    
    this:Dismiss("continue");
  end
end 

return GizmoOption;