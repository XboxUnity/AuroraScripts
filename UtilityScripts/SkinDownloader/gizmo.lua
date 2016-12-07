local Gizmo = {};         -- public namespace
local GP = {};            -- private namespace
local Xui = {};

function Gizmo.run( scriptData )
  local hGizmo = GizmoUI.CreateInstance();
  if hGizmo ~= nil then
    hGizmo:RegisterCallback( XuiMessage.Init, GP.fnOnInit ); 
    hGizmo:RegisterCallback( XuiMessage.Command, GP.fnOnCommand );    
    
    return hGizmo:InvokeUI(Script.GetBasePath(), "Skin Downloader", "scene.xur", "skin.xur", scriptData );
  end
end

function GP.fnOnInit( this, initData )
  
  -- Find our total controls 
  Xui["Nombre"] = this:RegisterControl( XuiObject.Label, "Nombre" );
  Xui["Autor"] = this:RegisterControl( XuiObject.Label, "Autor" );
  Xui["Captura"] = this:RegisterControl( XuiObject.Image, "Captura" );
  
  Xui["lblNombre"] = this:RegisterControl( XuiObject.Label, "lblNombre" );
  Xui["lblAutor"] = this:RegisterControl( XuiObject.Label, "lblAutor" );
  
  -- Disable the A button
  this:SetCommandEnabled( GizmoCommand.A, true );
  this:SetCommandText( GizmoCommand.A, "Download" );
  
  this:SetCommandEnabled( GizmoCommand.X, true );
  this:SetCommandText( GizmoCommand.X, "More info" );
  
  -- Apply total counts 
  Xui.Nombre:SetText( (initData.nombre) .. " v" .. (initData.version) );
  Xui.Autor:SetText( (initData.autor) );
  
 
  -- Apply images
  Xui.Captura:SetImagePath( "screenshots\\" .. initData.id .. "_" .. initData.version .. ".jpg" );
  
end


function GP.fnOnCommand( this, commandType )
  if commandType == GizmoCommand.A then
    -- A button was pressed- so let's dismiss our UI and download
    this:Dismiss("download");  
  end
  if commandType == GizmoCommand.X then
	this:Dismiss("moreinfo");
  end
end 

-- Return our script functionality
return Gizmo;