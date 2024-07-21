scriptTitle = "Aurora Weather"
scriptAuthor = "Phoenix"
scriptVersion = 3
scriptDescription = "A simple weather application"
scriptIcon = "icon\\icon.xur";

-- Define script permissions to enable access to libraries
scriptPermissions = { "http" };

-- Include our helper functions / enumerations
require("AuroraUI");
json = require("json");
gizmo = require("Gizmo");

-- Global variables
State = {}; -- Stores the current state of the gizmo
Xui = {};   -- Stores handles of XUI objects

-- Main entry point to script
function main()
    -- Using our INI library, let's open our config file (file will be created if not found)
    -- TODO: Reset ini if missing "version" key or if version is less than 3
    local configFile = IniFile.LoadFile("settings.ini");
    if configFile == nil then
        print("Error opening the script configuration file.");
        goto EndScript
    end
    Script.SetProgress(20);

    -- Call our function to obtain Imperial or Metric unit system
    -- TODO: Convert to boolean, store as "true" or "false"
    local metric = IsUnitSystemMetric(configFile);
    Script.SetProgress(40);

    ::RequestQuery::

    -- Call our function to obtain our location
    local params = GetLocation(configFile);
    if params == nil then
        local msgData = Script.ShowMessageBox("Location Not Found",
            "The location entered was not found. Would you like to enter another location?", "Yes", "No");
        if msgData.Button == 1 then goto RequestQuery else goto EndScript end
    end
    Script.SetProgress(60);

    -- Add our metric flag to our params table for convenience
    params["metric"] = metric == "1";

    -- Call our function to obtain the weather forecast data
    local weatherData = RequestWeatherData(params);
    if weatherData == nil then
        Script.ShowNotification("Error downloading weather info. Please try again later.");
        goto EndScript
    end
    Script.SetProgress(80);

    local scriptData = {};
---@diagnostic disable-next-line: need-check-nil
    scriptData["location"] = params.location; -- if we made it here, we have a location
    scriptData["weather"] = weatherData;

    -- Pass our weather data to our gizmo and run the scene
    local cmd = gizmo.run(scriptData);
    if cmd.Result == "location" then
        Script.SetStatus("Resetting location...");
        Script.SetProgress(40);

        -- Clear our query string from our config
        local savedLat = configFile:WriteValue("config", "latitude", "");
        local savedLon = configFile:WriteValue("config", "longitude", "");
        if savedLat == false or savedLon == false then
            local msgData = Script.ShowMessageBox("Aurora Weather", "There was an error reseting your location.", "OK");
            if msgData.Button == 1 then
                goto EndScript
            end
        end

        -- Request new location
        goto RequestQuery
    end
    Script.SetProgress(100);

    ::EndScript::
end

-- Helper function to retrieve or set configured measurement system
-- Params: The INI file object to read and write configuration settings.
-- Returns: A string containing the metric flag (0 = Imperial, 1 = Metric).
function IsUnitSystemMetric(iniFile)
    -- Retrieve our unit system
    local metric = iniFile:ReadValue("config", "metric", "");
    local needsave = false;

    -- If our metric flag is invalid, show message box UI for user selection
    if metric == "" then
        metric = "0";
        local msgData = Script.ShowMessageBox("Units", "Which measurement system would you like to use?",
            "Imperial (US)",
            "Metric");
        metric = msgData.Button == 1 and "0" or "1";
        needsave = true;
    end

    -- Now that we have a valid metric selection, let's save it to our config INI
    if needsave == true then
        local retval = iniFile:WriteValue("config", "metric", metric);
        if retval == false then
            local msgData = Script.ShowMessageBox("Aurora Weather", "There was an error saving unit system.", "OK");
            if msgData.Button == 1 then
                goto CleanUp
            end
        end
    end

    ::CleanUp::

    return metric;
end

-- Helper function to retrieve or set configured location and coordinates
-- using the Open-Meteo Geocoding API (https://open-meteo.com/en/docs/geocoding-api).
-- Params: The INI file object to read and write configuration settings.
-- Returns: A table with the location name, latitude, and longitude, or nil if lookup failed.
function GetLocation(iniFile)
    -- TODO: Save as single string, parse on read (coords = "latitude,longitude")
    -- TODO: If custom coords given, ask for location name (default is lat/lon string)
    local location = iniFile:ReadValue("config", "location", "")
    local latitude = iniFile:ReadValue("config", "latitude", "")
    local longitude = iniFile:ReadValue("config", "longitude", "")
    local needsave = false

    -- If the coordinates are empty, prompt the user for input
    if latitude == "" or longitude == "" or location == "" then
        local lastDefault = ""
        local keyboardData = Script.ShowKeyboard("Aurora Weather",
            "Enter city, postal code, or geo-coordinates (eg, 26.71534,-80.05337).",
            lastDefault, KeyboardFlag.Highlight)

        if keyboardData.Canceled == false then
            -- Check if input is in latitude,longitude format
            local input = keyboardData.Buffer
            local lat, lon = nil, nil

            for value in string.gmatch(input, "[^,]+") do
                if not lat then
                    lat = value
                elseif not lon then
                    lon = value
                end
            end

            if lat and lon and tonumber(lat) and tonumber(lon) then
                location = input
                latitude = lat
                longitude = lon
                needsave = true
            else
                -- If not, search for the location using Open-Meteo API
                Script.SetStatus("Searching for matching locations...")
                local baseUrl = "https://geocoding-api.open-meteo.com/v1/search/"
                local resp = Http.Get(baseUrl .. "?name=" .. Http.UrlEncode(input) .. "&count=100")
                if resp.Success then
                    -- Parse the response
                    local data = json:decode(resp.OutputData)
                    if data and data.results and #data.results > 0 then
                        Script.SetStatus("Building location list...")
                        local listContent = {}
                        for k, v in ipairs(data.results) do
                            listContent[k] = v.name .. ", " .. (v.admin1 or "") .. ", " .. (v.country or "")
                        end

                        -- Show the list of matching locations
                        local popupData = Script.ShowPopupList("Select Location", "No Locations Found", listContent)
                        if popupData.Selected then
                            local selectedLocation = data.results[popupData.Selected.Key]
                            location = selectedLocation.name
                            latitude = selectedLocation.latitude
                            longitude = selectedLocation.longitude
                            needsave = true
                        end
                    else
                        location = nil
                        latitude = nil
                        longitude = nil
                        goto CleanUp
                    end
                end
            end
        end
    end

    -- TODO: Don't save if no location chosen from list

    -- Save the coordinates if necessary
    if needsave == true then
        local savedLoc = iniFile:WriteValue("config", "location", location)
        local savedLat = iniFile:WriteValue("config", "latitude", latitude)
        local savedLon = iniFile:WriteValue("config", "longitude", longitude)
        if savedLoc == false or savedLat == false or savedLon == false then
            local msgData = Script.ShowMessageBox("Aurora Weather", "There was an error saving your location.", "OK")
            if msgData.Button == 1 then
                location = nil
                latitude = nil
                longitude = nil
                goto CleanUp
            end
        end
    end

    ::CleanUp::

    local coords = nil
    if latitude and longitude and location then
        coords = {
            location = location,
            latitude = tonumber(latitude),
            longitude = tonumber(longitude)
        }
    end

    return coords
end

-- Helper function to request current conditions and forecast data from the
-- Open-Meteo Weather Forecast API (https://open-meteo.com/en/docs).
-- Params: A table containing the requesting location's latitude, longitude, and metric flag.
-- Returns: A table containing the current conditions and forecast data, or nil if the request failed.
function RequestWeatherData(params)
    local weatherData = nil
    if params ~= nil then
        Script.SetStatus("Fetching weather data...")

        -- Get weather data response
        local resp = Http.Get(GetAPIEndpointUrl(params))
        if resp.Success == true then
            local weather = json:decode(resp.OutputData)
            if weather then
                weatherData = {
                    Conditions = weather.current,
                    Forecast = weather.daily,
                    ConditionsUnits = weather.current_units,
                    ForecastUnits = weather.daily_units
                }
            end
        end
    end

    return weatherData
end

-- Helper function to construct the endpoint URL and query string for weather forecast API requests
-- Params: A table containing the requesting location's latitude and longitude, and metric flag.
-- Returns: A string containing the full URL to the API endpoint.
function GetAPIEndpointUrl(params)
    local baseUrl = "https://api.open-meteo.com/v1/forecast/"
    local queryParams = {
        latitude = params.latitude,
        longitude = params.longitude,
        timezone = "auto",
        temperature_unit = params.metric and "celsius" or "fahrenheit",
        wind_speed_unit = params.metric and "kmh" or "mph",
        precipitation_unit = params.metric and "mm" or "inch",
        forecast_days = 4,
        current = "temperature_2m,dew_point_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,weather_code",
        daily = "temperature_2m_min,temperature_2m_max,weather_code",
    }

    local queryStr = "?"
    for k, v in pairs(queryParams) do
        queryStr = queryStr .. "&" .. k .. "=" .. v
    end

    return baseUrl .. queryStr
end
