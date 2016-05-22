scriptTitle = "LiNK Top-5"
scriptAuthor = "Phoenix"
scriptVersion = 1
scriptDescription = "See the top-5 active games on LiNK."
scriptIcon = "icon.png";
 
-- Define script permissions to enable access to libraries
scriptPermissions = { "http" }  

-- Include our helper functions / enumerations
require("AuroraUI");  
json = require("json");
gizmo = require("Gizmo"); 

-- Main entry point to script
function main()  

  -- Start by creating our directory for our game icons 
  Script.SetStatus( "Initializing script...");
  Script.CreateDirectory( "GameIcons" );

  -- Run our method to obtain the LiNK top-5
  local linkInfo = nil;
  ::DownloadTop5::
  linkInfo = DownloadLiNKTop5();
  if linkInfo ~= nil then    
    -- Pass our LiNK data to our gizmo and run the scene 
    local cmd = gizmo.run( linkInfo );
    if cmd.Result == "refresh" then    
      Script.SetStatus("Refreshing..."); 
      goto DownloadTop5;
    end
  else 
    Script.ShowNotification( "" );
  end
end


 -- Helper function to download current/forecast weather data
 function DownloadLiNKTop5()
  local infoTable = {};
  Script.SetStatus("Obtaining LiNK data..." );
  Script.SetProgress( 25 );
  local url = "http://phoenix.xboxunity.net/linkgizmo.php";
  local httpData = Http.Get( url );
  if httpData.Success == true then 
    infoTable = json:decode(httpData.OutputData);    
    
    -- Download icons for each game in the top 5 and store in game icons directory
    local counter = 1;
    for k,v in pairs(infoTable.rooms) do
      local iconUrl  = v.icon;
      local filename = "GameIcons\\" .. v.titleid .. ".png";
      if Script.FileExists( filename ) == false then 
        local httpIcon = Http.Get( iconUrl, filename );
        if httpData.Success == true then 
          print("icon '" .. filename .. "' download successfully" );
        end
      end
      
      Script.SetProgress( 25 + counter * 15 );
      counter = counter + 1;
    end
  else 
    infoTable = nil;
  end
  
  -- return table
  return infoTable;
 end