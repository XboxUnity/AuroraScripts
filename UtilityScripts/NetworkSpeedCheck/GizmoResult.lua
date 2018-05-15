local GizmoResult = {};        -- public namespace
local GP_Result = {};          -- private namespace
local Xui_Result = {};

function GizmoResult.run( scriptData )
  local hGizmo = GizmoUI.CreateInstance();
  if hGizmo ~= nil then  
    hGizmo:RegisterCallback( XuiMessage.Init, GP_Result.fnOnInit ); 
    hGizmo:RegisterCallback( XuiMessage.Command, GP_Result.fnOnCommand );    
    
    return hGizmo:InvokeUI(Script.GetBasePath(), "Network Speed Check - Result", "skin\\result.xur", "skin\\skin.xur", scriptData );
  end
end

function GP_Result.fnOnInit( this, initData )
  Xui_Result["downstreamLable"] = this:RegisterControl( XuiObject.Label, "downstreamLable" );
  Xui_Result["downstreamValueMbit"] = this:RegisterControl( XuiObject.Label, "downstreamValueMbit" );
  Xui_Result["downstreamValueMByte"] = this:RegisterControl( XuiObject.Label, "downstreamValueMByte" );
  Xui_Result["upstreamLable"] = this:RegisterControl( XuiObject.Label, "upstreamLable" );
  Xui_Result["upstreamValueMbit"] = this:RegisterControl( XuiObject.Label, "upstreamValueMbit" );
  Xui_Result["upstreamValueMByte"] = this:RegisterControl( XuiObject.Label, "upstreamValueMByte" );
  Xui_Result["localIpLable"] = this:RegisterControl( XuiObject.Label, "localIpLable" );
  Xui_Result["localIpValue"] = this:RegisterControl( XuiObject.Label, "localIpValue" );
  Xui_Result["remoteIpLable"] = this:RegisterControl( XuiObject.Label, "remoteIpLable" );
  Xui_Result["remoteIpValue"] = this:RegisterControl( XuiObject.Label, "remoteIpValue" );
  Xui_Result["serverIpLable"] = this:RegisterControl( XuiObject.Label, "serverIpLable" );
  Xui_Result["serverIpValue"] = this:RegisterControl( XuiObject.Label, "serverIpValue" );
  Xui_Result["pingLable"] = this:RegisterControl( XuiObject.Label, "pingLable" );
  Xui_Result["pingValue"] = this:RegisterControl( XuiObject.Label, "pingValue" );
  Xui_Result["hopsLable"] = this:RegisterControl( XuiObject.Label, "hopsLable" );
  Xui_Result["hopsValue"] = this:RegisterControl( XuiObject.Label, "hopsValue" );
  Xui_Result["jitterLable"] = this:RegisterControl( XuiObject.Label, "jitterLable" );
  Xui_Result["jitterValue"] = this:RegisterControl( XuiObject.Label, "jitterValue" );
  
  Xui_Result["downstreamIcon"] = this:RegisterControl( XuiObject.Image, "downstreamIcon" );
  Xui_Result["upstreamIcon"] = this:RegisterControl( XuiObject.Image, "upstreamIcon" );
  
  local downstreamInMbitPerSecond  = tostring(round((initData.downstreamInBPS/1024/1024*8), 3))   .. " Mbit/s";
  local downstreamInMBytePerSecond = tostring(round((initData.downstreamInBPS/1024/1024),   3))   .. " MByte/s";
  local upstreamInMbitPerSecond    = tostring(round((initData.upstreamInBPS/1024/1024*8),   3))   .. " Mbit/s";
  local upstreamInMBytePerSecond   = tostring(round((initData.upstreamInBPS/1024/1024),     3))   .. " MByte/s";
  
  Xui_Result.downstreamValueMbit:SetText(  "-> " .. downstreamInMbitPerSecond );
  Xui_Result.downstreamValueMByte:SetText( "-> " .. downstreamInMBytePerSecond );
  Xui_Result.upstreamValueMbit:SetText(    "-> " .. upstreamInMbitPerSecond );
  Xui_Result.upstreamValueMByte:SetText(   "-> " .. upstreamInMBytePerSecond );
  Xui_Result.localIpValue:SetText( initData.localIp );
  Xui_Result.remoteIpValue:SetText( initData.remoteIp );
  Xui_Result.serverIpValue:SetText( initData.serverIp );
  Xui_Result.pingValue:SetText( initData.ping.avg .. " ms");
  Xui_Result.hopsValue:SetText( initData.hops );
  Xui_Result.jitterValue:SetText( initData.jitter .. " ms");
  
  Xui_Result.downstreamIcon:SetImagePath( "images\\" .. "downstreamArrow.png" );
  Xui_Result.upstreamIcon:SetImagePath( "images\\" .. "upstreamArrow.png" );
  
  this:SetCommandEnabled( GizmoCommand.A, false ); 
end

function GP_Result.fnOnCommand( this, commandType )
  -- do nothing, but close
end 

return GizmoResult;