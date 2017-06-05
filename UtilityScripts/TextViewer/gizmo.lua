local Gizmo = {};         -- public namespace
local GP = {};            -- private namespace
local Xui = {};

function Gizmo.run( scriptData )
  local hGizmo = GizmoUI.CreateInstance();
  if hGizmo ~= nil then  
    hGizmo:RegisterCallback( XuiMessage.Init, GP.fnOnInit ); 
    hGizmo:RegisterCallback( XuiMessage.Command, GP.fnOnCommand );    
    
    return hGizmo:InvokeUI(Script.GetBasePath(), "Text Viewer | " .. scriptData.path, "skin\\scene.xur", "skin\\skin.xur", scriptData );
  end
end

function GP.fnOnInit( this, initData )
  Xui["textArea"] = this:RegisterControl( XuiObject.Edit, "textArea" );
 
  Xui.textArea:SetText( initData.text );
 
  this:SetCommandEnabled( GizmoCommand.A, false );
end

function GP.fnOnCommand( this, commandType )
  -- do Nothing
end 

return Gizmo;