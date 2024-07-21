local Gizmo = {}; -- public namespace
local GP = {};    -- private namespace
local Xui = {};

function Gizmo.run(scriptData)
    local hGizmo = GizmoUI.CreateInstance();
    if hGizmo ~= nil then
        hGizmo:RegisterCallback(XuiMessage.Init, GP.fnOnInit);
        hGizmo:RegisterCallback(XuiMessage.Command, GP.fnOnCommand);

        -- Run our gizmo with access to our init data
        GP['location'] = scriptData.location;

        local basepath = Script.GetBasePath() .. "skin\\";
        return hGizmo:InvokeUI(basepath, "Aurora Weather", "weatherScene.xur", "weatherSkin.xur", scriptData.weather);
    end
end

function GP.fnOnInit(this, initData)
    -- Locate and register our tab1 controls (current conditions)
    Xui["location"] = this:RegisterControl(XuiObject.Label, "location");
    Xui["temp"] = this:RegisterControl(XuiObject.Label, "temperature");
    Xui["dewpoint"] = this:RegisterControl(XuiObject.Label, "dewpoint");
    Xui["humidity"] = this:RegisterControl(XuiObject.Label, "humidity");
    Xui["windspeed"] = this:RegisterControl(XuiObject.Label, "windspeed");
    Xui["weather"] = this:RegisterControl(XuiObject.Label, "weather");
    Xui["imgIcon"] = this:RegisterControl(XuiObject.Image, "imgIcon");

    -- Define our control tables for our forecast controls
    Xui["forecast"] = {}
    Xui.forecast["day1"] = {}
    Xui.forecast["day2"] = {}
    Xui.forecast["day3"] = {}
    Xui.forecast["day4"] = {}

    -- Locate and register our tab2 controls (4-day forecast)
    Xui.forecast.day1["temphi"] = this:RegisterControl(XuiObject.Label, "d1temphi");
    Xui.forecast.day1["templo"] = this:RegisterControl(XuiObject.Label, "d1templo");
    Xui.forecast.day1["dayofweek"] = this:RegisterControl(XuiObject.Label, "d1dayofweek");
    Xui.forecast.day1["image"] = this:RegisterControl(XuiObject.Image, "d1image");

    Xui.forecast.day2["temphi"] = this:RegisterControl(XuiObject.Label, "d2temphi");
    Xui.forecast.day2["templo"] = this:RegisterControl(XuiObject.Label, "d2templo");
    Xui.forecast.day2["dayofweek"] = this:RegisterControl(XuiObject.Label, "d2dayofweek");
    Xui.forecast.day2["image"] = this:RegisterControl(XuiObject.Image, "d2image");

    Xui.forecast.day3["temphi"] = this:RegisterControl(XuiObject.Label, "d3temphi");
    Xui.forecast.day3["templo"] = this:RegisterControl(XuiObject.Label, "d3templo");
    Xui.forecast.day3["dayofweek"] = this:RegisterControl(XuiObject.Label, "d3dayofweek");
    Xui.forecast.day3["image"] = this:RegisterControl(XuiObject.Image, "d3image");

    Xui.forecast.day4["temphi"] = this:RegisterControl(XuiObject.Label, "d4temphi");
    Xui.forecast.day4["templo"] = this:RegisterControl(XuiObject.Label, "d4templo");
    Xui.forecast.day4["dayofweek"] = this:RegisterControl(XuiObject.Label, "d4dayofweek");
    Xui.forecast.day4["image"] = this:RegisterControl(XuiObject.Image, "d4image");

    -- Set our command buttons
    this:SetCommandEnabled(GizmoCommand.A, false);
    this:SetCommandText(GizmoCommand.X, "Reset Location");
    this:SetCommandEnabled(GizmoCommand.X, true);

    -- Populate our weather data
    --print(initData);

    -- Set location name
    Xui.location:SetText(GP.location);

    -- Set current conditions
    Xui.temp:SetText(initData.Conditions.temperature_2m .. initData.ConditionsUnits.temperature_2m);
    Xui.dewpoint:SetText(initData.Conditions.dew_point_2m .. initData.ConditionsUnits.dew_point_2m);
    Xui.humidity:SetText(initData.Conditions.relative_humidity_2m .. initData.ConditionsUnits.relative_humidity_2m);
    if initData.Conditions.wind_speed_10m ~= 0 then
        Xui.windspeed:SetText(GP.degreesToCardinal(initData.Conditions.wind_direction_10m) .. " at " ..
            initData.Conditions.wind_speed_10m .. " " .. initData.ConditionsUnits.wind_speed_10m);
    else
        Xui.windspeed:SetText(initData.Conditions.wind_speed_10m .. " " .. initData.ConditionsUnits.wind_speed_10m);
    end
    Xui.weather:SetText(GP.lookupWeatherCode(initData.Conditions.weather_code).description);
    Xui.imgIcon:SetImagePath(GP.lookupWeatherCode(initData.Conditions.weather_code).image);

    -- Set forecast day of week
    Xui.forecast.day1.dayofweek:SetText("Today");
    Xui.forecast.day2.dayofweek:SetText("Tomorrow");
    Xui.forecast.day3.dayofweek:SetText(GP.dateToDayOfWeek(initData.Forecast.time[3]));
    Xui.forecast.day4.dayofweek:SetText(GP.dateToDayOfWeek(initData.Forecast.time[4]));

    -- Set forecast image
    Xui.forecast.day1.image:SetImagePath(GP.lookupWeatherCode(initData.Forecast.weather_code[1]).image);
    Xui.forecast.day2.image:SetImagePath(GP.lookupWeatherCode(initData.Forecast.weather_code[2]).image);
    Xui.forecast.day3.image:SetImagePath(GP.lookupWeatherCode(initData.Forecast.weather_code[3]).image);
    Xui.forecast.day4.image:SetImagePath(GP.lookupWeatherCode(initData.Forecast.weather_code[4]).image);

    -- Set forecast high temp
    Xui.forecast.day1.temphi:SetText(initData.Forecast.temperature_2m_max[1] .. initData.ForecastUnits.temperature_2m_max);
    Xui.forecast.day2.temphi:SetText(initData.Forecast.temperature_2m_max[2] .. initData.ForecastUnits.temperature_2m_max);
    Xui.forecast.day3.temphi:SetText(initData.Forecast.temperature_2m_max[3] .. initData.ForecastUnits.temperature_2m_max);
    Xui.forecast.day4.temphi:SetText(initData.Forecast.temperature_2m_max[4] .. initData.ForecastUnits.temperature_2m_max);

    -- Set forecast low temp
    Xui.forecast.day1.templo:SetText(initData.Forecast.temperature_2m_min[1] .. initData.ForecastUnits.temperature_2m_min);
    Xui.forecast.day2.templo:SetText(initData.Forecast.temperature_2m_min[2] .. initData.ForecastUnits.temperature_2m_min);
    Xui.forecast.day3.templo:SetText(initData.Forecast.temperature_2m_min[3] .. initData.ForecastUnits.temperature_2m_min);
    Xui.forecast.day4.templo:SetText(initData.Forecast.temperature_2m_min[4] .. initData.ForecastUnits.temperature_2m_min);
end

function GP.fnOnCommand(this, commandType)
    if commandType == GizmoCommand.X then
        -- X button was pressed- so let's dismiss our UI and request a new location from the user
        this:Dismiss("location");
    end
end

local weatherCodesTable = {
    [0] = { description = "Clear skies", image = "weather\\clear.png" },
    [1] = { description = "Mostly clear", image = "weather\\mostlysunny.png" },
    [2] = { description = "Partly cloudy", image = "weather\\partlycloudy.png" },
    [3] = { description = "Overcast", image = "weather\\cloudy.png" },
    [45] = { description = "Fog", image = "weather\\hazy.png" },
    [48] = { description = "Depositing rime fog", image = "weather\\hazy.png" },
    [51] = { description = "Light drizzle", image = "weather\\chancerain.png" },
    [53] = { description = "Moderate drizzle", image = "weather\\rain.png" },
    [55] = { description = "Dense drizzle", image = "weather\\rain.png" },
    [56] = { description = "Light freezing drizzle", image = "weather\\chancesleet.png" },
    [57] = { description = "Dense freezing drizzle", image = "weather\\sleet.png" },
    [61] = { description = "Slight rain", image = "weather\\chancerain.png" },
    [63] = { description = "Moderate rain", image = "weather\\rain.png" },
    [65] = { description = "Heavy rain", image = "weather\\rain.png" },
    [66] = { description = "Light freezing rain", image = "weather\\chancesleet.png" },
    [67] = { description = "Heavy freezing rain", image = "weather\\sleet.png" },
    [71] = { description = "Slight snow fall", image = "weather\\chanceflurries.png" },
    [73] = { description = "Moderate snow fall", image = "weather\\flurries.png" },
    [75] = { description = "Heavy snow fall", image = "weather\\snow.png" },
    [77] = { description = "Snow grains", image = "weather\\snow.png" },
    [80] = { description = "Slight rain showers", image = "weather\\chancerain.png" },
    [81] = { description = "Moderate rain showers", image = "weather\\rain.png" },
    [82] = { description = "Violent rain showers", image = "weather\\rain.png" },
    [85] = { description = "Slight snow showers", image = "weather\\chancesnow.png" },
    [86] = { description = "Heavy snow showers", image = "weather\\snow.png" },
    [95] = { description = "Slight/moderate thunderstorms", image = "weather\\chancetstorms.png" },
    [96] = { description = "Slight thunderstorms with hail", image = "weather\\tstorms.png" },
    [99] = { description = "Heavy thunderstorms with hail", image = "weather\\tstorms.png" },
}

-- Returns a table containing a description and image filepath for a given WMO code
function GP.lookupWeatherCode(wmoCode)
    return weatherCodesTable[wmoCode] or { description = "Unknown", image = "weather\\unknown.png" };
end

-- Converts a wind direction in degrees to a cardinal direction
function GP.degreesToCardinal(degrees)
    local cardinals = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" };
    local index = math.floor((degrees + 22.5) / 45);
    return cardinals[index % 8];
end

-- Converts a date string ("2024-07-20") to the day of the week (Saturday) using Zeller's Congruence Algorithm
function GP.dateToDayOfWeek(dateStr)
    local year, month, day = dateStr:match("(%d+)-(%d+)-(%d+)")
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)

    if month < 3 then
        month = month + 12
        year = year - 1
    end

    local K = year % 100
    local J = math.floor(year / 100)
    local h = (day + math.floor((13 * (month + 1)) / 5) + K + math.floor(K / 4) + math.floor(J / 4) - 2 * J) % 7
    local daysOfWeek = { "Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" }

    return daysOfWeek[h + 1]
end

-- Return our script functionality
return Gizmo;
