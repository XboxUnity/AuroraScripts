scriptTitle = "Aurora Weather"
scriptAuthor = "Phoenix"
scriptVersion = 2
scriptDescription = "A sample weather application."
scriptIcon = "icon\\icon.xur";
 
-- Define script permissions to enable access to libraries
scriptPermissions = { "http" }  

-- Include our helper functions / enumerations
require("AuroraUI");  
json = require("json");
gizmo = require("Gizmo"); 

-- Global variables
State = {};   -- Stores the current state of the gizmo 
Xui = {};     -- Stores handles of XUI objects 

-- Main entry point to script
function main()  
  -- Using our INI library, let's open our config file (file will be created if not found)        
  local configFile = IniFile.LoadFile( "settings.ini" );
  if configFile == nil then 
    print( "An error occurred opening the script configuration file." );
    goto EndScript;
  end 

  -- Increment script progress bar
  Script.SetProgress( 5 );
  
  -- Call our function to obtain weather APIKey
  local apiKey = GetWeatherAPIKey( configFile ); 
  if apiKey == "" then 
    print("No API Key was provided- abandoning script." );
    goto EndScript;     
  end
  
  -- Increment script progress bar
  Script.SetProgress( 20 );  
  
  -- Call our function to obtain weather format
  local metric = GetWeatherFormat( configFile );
  if metric == "" then  
    print("An erro occurred obtaining weather format.  Defaulting to US.");
    metric = "0";
  end
  
  -- Increment script progress bar
  Script.SetProgress( 40 );    
  
  local queryUrl = "";
  ::RequestQuery::
  -- Call our function to obtain search location
  queryUrl = GetWeatherQueryURL( configFile, apiKey );    -- Example:  queryUrl = "/q/zmw:36420.3.99999"
  if queryUrl == "" then 
    print("No valid QueryURL was provided- abandoning script." );
    -- output message that no locations were found 
    local msgData = Script.ShowMessageBox( "Location Not Found", "The location entered was not found.  Would you like to enter another location?", "Yes", "No" );
    if msgData.Button == 1 then
      goto RequestQuery;
    else 
      goto EndScript; 
    end
  elseif queryUrl == "___" then 
    goto EndScript;
  end
  
  -- Increment script progress bar
  Script.SetProgress( 60 );      
  
  -- Now we have our queryURL and API Key
  local weatherData = DownloadWeatherInfo( apiKey, queryUrl );
  if weatherData == nil then 
    Script.ShowNotification( "An error occurred downloading weather info.  Please try again later" );
    goto EndScript;
  end
  
  -- Increment script progress bar
  Script.SetProgress( 80 );
  
  local scriptData = {};
  scriptData["weather"] = weatherData;
  scriptData["metric"] = metric;
    
  -- Pass our weather data to our gizmo and run the scene 
  local cmd = gizmo.run( scriptData );
  if cmd.Result == "location" then
    Script.SetStatus( "Resetting location..." );
    Script.SetProgress(40);
    
    -- Clear our query string form our config
    local retval = configFile:WriteValue( "config", "query", "" );
    if retval == false then
      local msgData = Script.ShowMessageBox( "Aurora Weather", "There was an error reseting your location.", "OK" );
      if msgData.Button == 1 then 
        goto EndScript;
      end
    end
    
    -- Request new location
    goto RequestQuery;
  end
  
  -- Increment script progress bar
  Script.SetProgress( 100 );  

  -- Point of exit for script
  ::EndScript::
end

-- Helper function to obtain US or Metric
function GetWeatherFormat( iniFile )
  -- Retrieve our metric format 
  local metric = iniFile:ReadValue( "config", "metric", "" );
  local needsave = false;
  
  -- If our metric flag is invalid, we need to popup a message box to accept users preference
  if metric == "" then
    metric = "0";
    ::GetMetricFlag::
    local msgData = Script.ShowMessageBox( "Units", "Which measurement system would you like to use?", "US", "Metric" );
    if msgData.Button == 1 then
      metric = "0"
    else 
      metric = "1"
    end
    
    needsave = true;
  end
  
  -- Now that we have a valid metric selection, let's save it into our INI
  if needsave == true then 
    local retval = iniFile:WriteValue( "config", "metric", metric );
    if retval == false then
      local msgData = Script.ShowMessageBox( "Aurora Weather", "There was an error saving your measurement type.\n\nContinue?", "Yes", "No" );
      if msgData.Button == 1 then 
        goto CleanUp;
      end
    end
  end
    
  ::CleanUp::  
  -- Return our measurement type (empty result means error)
  return metric;
end
  
-- Helper function to obtain and validate APIKey
function GetWeatherAPIKey( iniFile )
  -- Retrieve our API Key from our settings
  local apiKey = iniFile:ReadValue( "config", "apikey", "" );
  local needsave = false;
  -- Now if our apikey is invalid, we need to popup a keyboard to request it
  if apiKey == "" then 
    apiKey = "";
    ::EnterApiKey::  
    local keyboardData = Script.ShowKeyboard( "Aurora Keyboard", "Enter your Weather Underground API Key", "", KeyboardFlag.Highlight );
    if keyboardData.Canceled == false then 
      apiKey = keyboardData.Buffer;
      
      ::RetryAPIKeyDownload::
      -- Entered in key, so let's test if valid key 
      local url = "http://api.wunderground.com/api/" .. apiKey .. "/";
      local httpData = Http.Get( url ); 
      if httpData.Success == true then 
        -- Parse our data using our json library 
        local o = json:decode(httpData.OutputData);
        if o.response.error.type == "keynotfound" then 
          local msgData = Script.ShowMessageBox( "API Key Invalid", "The API Key entered was not valid.\n\nWould you like to enter another key?.", "Yes", "No" );
          if msgData.Button == 1 then 
            goto EnterApiKey;
          else 
            apiKey = "";
            goto CleanUp;
          end
        end
        -- APIKey was valid, and should not be nil at this point
        needsave = true;
      else
      -- Download failed- so popup a message asking to retry
        local msgData = Script.ShowMessageBox( "Aurora Weather", "Download for API Key validation has failed.\n\nTry again?", "Yes", "No" );
        if msgData.Button == 1 then 
         goto RetryAPIKeyDownload;
        else
          apiKey = "";
          goto CleanUp;
        end
      end 
    else
      local msgData = Script.ShowMessageBox( "Aurora Weather", "The API Key entered was not valid.\n\nWould you like to enter another key?.", "Yes", "No" );
      if msgData.Button == 1 then 
        goto EnterApiKey;
      else
        apiKey = "";      
        goto CleanUp;
      end    
    end
  end
  
  -- Now that we have a valid APIKey, let's save it into our INI
  if needsave == true then 
    local retval = iniFile:WriteValue( "config", "apikey", apiKey );
    if retval == false then
      local msgData = Script.ShowMessageBox( "Aurora Weather", "There was an error saving your API Key.\n\nContinue?", "Yes", "No" );
      if msgData.Button == 1 then 
        goto CleanUp;
      end
    end
  end
    
  ::CleanUp::  
  
  -- Return our apikey (empty key means error)
  return apiKey;
end

 -- Helper function to obtain a query URL
 function GetWeatherQueryURL( iniFile, apikey )
   -- Retrieve our QueryURL from our settings
  local queryUrl = iniFile:ReadValue( "config", "query", "" );
  print(queryUrl);
  local needsave = false;
  -- Now if our apikey is invalid, we need to popup a keyboard to request it
  if queryUrl == "" then 
    -- Ask user to enter city name for the search
    local lastDefault = "";
    local keyboardData = Script.ShowKeyboard( "Aurora Weather", "Enter the name of a location to search. (or advanced location taken from a websearch url, zmw:...)", lastDefault, KeyboardFlag.Highlight );
    if keyboardData.Canceled == false then 
	  if string.find(keyboardData.Buffer, "^zmw:") then 
			queryUrl = "/q/"..keyboardData.Buffer;			
            needsave = true;
	  elseif string.find(keyboardData.Buffer, "^%d*%.%d*%.%d*") then 
			queryUrl = "/q/zmw:"..keyboardData.Buffer;			
            needsave = true;
	  else 	
		Script.SetStatus("Searching for matching locations..." );
		-- Entered in key, so let's test if valid key 
		local url = "http://api.wunderground.com/api/" .. apikey .. "/q/" .. keyboardData.Buffer .. ".json";
		local httpData = Http.Get( url );
		if httpData.Success == true then
			-- Parse our results 
			local o = json:decode(httpData.OutputData);
			if o.response.results ~= nil then 
			Script.SetStatus("Building location list..." );
			local listContent = {};
			for k,v in pairs(o.response.results) do
				listContent[k] = v.city .. ", " .. v.state .. ", " .. v.country_name;
			end
			
			-- At this point we have a content list, so lets create a list
			local popupData = Script.ShowPopupList( "Select Location", "No Locations Found", listContent );
			if popupData.Selected ~= nil then 
				queryUrl = o.response.results[popupData.Selected.Key].l;
				needsave = true;
			end
			end
		end
	  end
    else 
       queryUrl = "___";
    end
  end
  
  if needsave == true then 
	local retval = iniFile:WriteValue( "config", "query", queryUrl );
    if retval == false then 
      local msgData = Script.ShowMessageBox( "Aurora Weather", "There was an error saving your location.\n\nContinue?", "Yes", "No");
      if msgData.Button == 1 then 
        queryUrl = "";
        goto CleanUp;
      end
    end
  end
 
  ::CleanUp::
  
  -- Return our query Url 
  return queryUrl;
 end
 
  -- Helper function to download current/forecast weather data
 function DownloadWeatherInfo( apikey, queryurl )
  local infoTable = {};
  if apikey ~= nil and queryurl ~= nil then
    Script.SetStatus("Downloading weather data..." );
    -- Entered in key, so let's test if valid key 
    local url = "http://api.wunderground.com/api/" .. apikey .. "/conditions/forecast" .. queryurl .. ".json";
    local httpData = Http.Get( url );
    if httpData.Success == true then 
      local o = json:decode(httpData.OutputData);
      if o.response.features.conditions == 1 then 
        infoTable["Conditions"] = o.current_observation;
      end 
      if o.response.features.forecast == 1 then 
        infoTable["Forecast"] = o.forecast.simpleforecast.forecastday;  
      end
    else
      infoTable = nil;
    end
  end
  
  -- return table
  return infoTable;
 end