local Gizmo = {};         -- public namespace
local GP = {};            -- private namespace
local Xui = {};

function Gizmo.run( scriptData )
  local hGizmo = GizmoUI.CreateInstance();
  if hGizmo ~= nil then  
    hGizmo:RegisterCallback( XuiMessage.Init, GP.fnOnInit ); 
    hGizmo:RegisterCallback( XuiMessage.Command, GP.fnOnCommand );    
    
    return hGizmo:InvokeUI(Script.GetBasePath(), "Network Speed Check", "skin\\scene.xur", "skin\\skin.xur", scriptData );
  end
end

function GP.fnOnInit( this, initData )
  Xui["downstreamLable"] = this:RegisterControl( XuiObject.Label, "downstreamLable" );
  Xui["downstreamValueMbit"] = this:RegisterControl( XuiObject.Label, "downstreamValueMbit" );
  Xui["downstreamValueMByte"] = this:RegisterControl( XuiObject.Label, "downstreamValueMByte" );
  Xui["upstreamLable"] = this:RegisterControl( XuiObject.Label, "upstreamLable" );
  Xui["upstreamValueMbit"] = this:RegisterControl( XuiObject.Label, "upstreamValueMbit" );
  Xui["upstreamValueMByte"] = this:RegisterControl( XuiObject.Label, "upstreamValueMByte" );
  Xui["localIpLable"] = this:RegisterControl( XuiObject.Label, "localIpLable" );
  Xui["localIpValue"] = this:RegisterControl( XuiObject.Label, "localIpValue" );
  Xui["remoteIpLable"] = this:RegisterControl( XuiObject.Label, "remoteIpLable" );
  Xui["remoteIpValue"] = this:RegisterControl( XuiObject.Label, "remoteIpValue" );
  Xui["serverIpLable"] = this:RegisterControl( XuiObject.Label, "serverIpLable" );
  Xui["serverIpValue"] = this:RegisterControl( XuiObject.Label, "serverIpValue" );
  Xui["pingLable"] = this:RegisterControl( XuiObject.Label, "pingLable" );
  Xui["pingValue"] = this:RegisterControl( XuiObject.Label, "pingValue" );
  Xui["hopsLable"] = this:RegisterControl( XuiObject.Label, "hopsLable" );
  Xui["hopsValue"] = this:RegisterControl( XuiObject.Label, "hopsValue" );
  Xui["jitterLable"] = this:RegisterControl( XuiObject.Label, "jitterLable" );
  Xui["jitterValue"] = this:RegisterControl( XuiObject.Label, "jitterValue" );
  
  Xui["downstreamIcon"] = this:RegisterControl( XuiObject.Image, "downstreamIcon" );
  Xui["upstreamIcon"] = this:RegisterControl( XuiObject.Image, "upstreamIcon" );
  
  local downstreamInMbitPerSecond  = tostring(round((initData.downstreamInBPS/1024/1024*8), 3))   .. " Mbit/s";
  local downstreamInMBytePerSecond = tostring(round((initData.downstreamInBPS/1024/1024),   3))   .. " MByte/s";
  local upstreamInMbitPerSecond    = tostring(round((initData.upstreamInBPS/1024/1024*8),   3))   .. " Mbit/s";
  local upstreamInMBytePerSecond   = tostring(round((initData.upstreamInBPS/1024/1024),     3))   .. " MByte/s";
  
  Xui.downstreamValueMbit:SetText(  "-> " .. downstreamInMbitPerSecond );
  Xui.downstreamValueMByte:SetText( "-> " .. downstreamInMBytePerSecond );
  Xui.upstreamValueMbit:SetText(    "-> " .. upstreamInMbitPerSecond );
  Xui.upstreamValueMByte:SetText(   "-> " .. upstreamInMBytePerSecond );
  Xui.localIpValue:SetText( initData.localIp );
  Xui.remoteIpValue:SetText( initData.remoteIp );
  Xui.serverIpValue:SetText( initData.serverIp );
  Xui.pingValue:SetText( initData.ping.avg .. " ms");
  Xui.hopsValue:SetText( initData.hops );
  Xui.jitterValue:SetText( initData.jitter .. " ms");
  
  Xui.downstreamIcon:SetImagePath( "images\\" .. "downstreamArrow.png" );
  Xui.upstreamIcon:SetImagePath( "images\\" .. "upstreamArrow.png" );
  
  this:SetCommandEnabled( GizmoCommand.A, false ); 
end

function GP.fnOnCommand( this, commandType )
  -- do nothing, but close
end 

return Gizmo;