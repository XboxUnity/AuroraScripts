local Gizmo = {}; -- public namespace
local GP = {}; -- private namespace
local Xui = {};

function Gizmo.run(scriptData)
    local hGizmo = GizmoUI.CreateInstance();
    if hGizmo ~= nil then
        hGizmo:RegisterCallback(XuiMessage.Init, GP.fnOnInit);
        hGizmo:RegisterCallback(XuiMessage.Command, GP.fnOnCommand);

        -- Run our gizmo with access to our init data
        GP['metric'] = scriptData.metric;

        local basepath = Script.GetBasePath() .. "skin\\";
        return hGizmo:InvokeUI(basepath, "Aurora Weather", "weatherScene.xur", "weatherSkin.xur", scriptData.weather);
    end
end

function GP.fnOnInit(this, initData)
    -- Find our tab1 controls
    Xui["location"] = this:RegisterControl(XuiObject.Label, "location");
    Xui["temp"] = this:RegisterControl(XuiObject.Label, "temperature");
    Xui["dewpoint"] = this:RegisterControl(XuiObject.Label, "dewpoint");
    Xui["humidity"] = this:RegisterControl(XuiObject.Label, "humidity");
    Xui["windspeed"] = this:RegisterControl(XuiObject.Label, "windspeed");
    Xui["weather"] = this:RegisterControl(XuiObject.Label, "weather");
    Xui["imgIcon"] = this:RegisterControl(XuiObject.Image, "imgIcon");

    -- Define our forecast control tables
    Xui["forecast"] = {}
    Xui.forecast["day1"] = {}
    Xui.forecast["day2"] = {}
    Xui.forecast["day3"] = {}
    Xui.forecast["day4"] = {}

    -- Find controls for day 1 forecast
    Xui.forecast.day1["temphi"] = this:RegisterControl(XuiObject.Label, "d1temphi");
    Xui.forecast.day1["templo"] = this:RegisterControl(XuiObject.Label, "d1templo");
    Xui.forecast.day1["dayofweek"] = this:RegisterControl(XuiObject.Label, "d1dayofweek");
    Xui.forecast.day1["image"] = this:RegisterControl(XuiObject.Image, "d1image");

    -- Find controls for day 2 forecast
    Xui.forecast.day2["temphi"] = this:RegisterControl(XuiObject.Label, "d2temphi");
    Xui.forecast.day2["templo"] = this:RegisterControl(XuiObject.Label, "d2templo");
    Xui.forecast.day2["dayofweek"] = this:RegisterControl(XuiObject.Label, "d2dayofweek");
    Xui.forecast.day2["image"] = this:RegisterControl(XuiObject.Image, "d2image");

    -- Find controls for day 3 forecast
    Xui.forecast.day3["temphi"] = this:RegisterControl(XuiObject.Label, "d3temphi");
    Xui.forecast.day3["templo"] = this:RegisterControl(XuiObject.Label, "d3templo");
    Xui.forecast.day3["dayofweek"] = this:RegisterControl(XuiObject.Label, "d3dayofweek");
    Xui.forecast.day3["image"] = this:RegisterControl(XuiObject.Image, "d3image");

    -- Find controls for day 4 forecast
    Xui.forecast.day4["temphi"] = this:RegisterControl(XuiObject.Label, "d4temphi");
    Xui.forecast.day4["templo"] = this:RegisterControl(XuiObject.Label, "d4templo");
    Xui.forecast.day4["dayofweek"] = this:RegisterControl(XuiObject.Label, "d4dayofweek");
    Xui.forecast.day4["image"] = this:RegisterControl(XuiObject.Image, "d4image");

    -- Set our command buttons
    this:SetCommandEnabled(GizmoCommand.A, false);
    this:SetCommandText(GizmoCommand.X, "Location");
    this:SetCommandEnabled(GizmoCommand.X, true);

    -- print(initData);
    -- Fill in our data
    Xui.location:SetText(initData.Conditions.display_location.full);

    -- Define some variables to help
    local tempSuffix = "°" .. (GP.metric == "1" and "C" or "F")
    local speedSuffix = GP.metric == "1" and " kph " or " mph ";

    -- Update current condition fields
    local temp_key = GP.metric == "1" and "temp_c" or "temp_f";
    local dewpoint_key = GP.metric == "1" and "dewpoint_c" or "dewpoint_f";
    local windspeed_key = GP.metric == "1" and "wind_kph" or "wind_mph";

    Xui.temp:SetText(initData.Conditions[temp_key] .. tempSuffix);
    Xui.dewpoint:SetText(initData.Conditions[dewpoint_key] .. tempSuffix);
    Xui.humidity:SetText(initData.Conditions.relative_humidity);
    if initData.Conditions.wind_mph ~= 0 then
        Xui.windspeed:SetText(initData.Conditions[windspeed_key] .. speedSuffix .. initData.Conditions.wind_dir);
    else
        Xui.windspeed:SetText(initData.Conditions.wind_string);
    end
    Xui.weather:SetText(initData.Conditions.weather);
    Xui.imgIcon:SetImagePath("weather\\" .. initData.Conditions.icon .. ".png");

    -- Update forecast weekday
    Xui.forecast.day1.dayofweek:SetText("Today");
    Xui.forecast.day2.dayofweek:SetText("Tomorrow");
    Xui.forecast.day3.dayofweek:SetText(initData.Forecast[3].date.weekday);
    Xui.forecast.day4.dayofweek:SetText(initData.Forecast[4].date.weekday);

    -- Update forecast image
    Xui.forecast.day1.image:SetImagePath("weather\\" .. initData.Forecast[1].icon .. ".png");
    Xui.forecast.day2.image:SetImagePath("weather\\" .. initData.Forecast[2].icon .. ".png");
    Xui.forecast.day3.image:SetImagePath("weather\\" .. initData.Forecast[3].icon .. ".png");
    Xui.forecast.day4.image:SetImagePath("weather\\" .. initData.Forecast[4].icon .. ".png");

    local temp_key = GP.metric == "1" and "celsius" or "fahrenheit";

    -- Update forecast high temp
    Xui.forecast.day1.temphi:SetText(initData.Forecast[1].high[temp_key] .. tempSuffix);
    Xui.forecast.day2.temphi:SetText(initData.Forecast[2].high[temp_key] .. tempSuffix);
    Xui.forecast.day3.temphi:SetText(initData.Forecast[3].high[temp_key] .. tempSuffix);
    Xui.forecast.day4.temphi:SetText(initData.Forecast[4].high[temp_key] .. tempSuffix);

    -- Update forecast low temp
    Xui.forecast.day1.templo:SetText(initData.Forecast[1].low[temp_key] .. tempSuffix);
    Xui.forecast.day2.templo:SetText(initData.Forecast[2].low[temp_key] .. tempSuffix);
    Xui.forecast.day3.templo:SetText(initData.Forecast[3].low[temp_key] .. tempSuffix);
    Xui.forecast.day4.templo:SetText(initData.Forecast[4].low[temp_key] .. tempSuffix);
end

function GP.fnOnCommand(this, commandType)
    if commandType == GizmoCommand.X then
        -- X button was pressed- so let's dismiss our UI and request a new location from the user
        this:Dismiss("location");
    end
end

-- Return our script functionality
return Gizmo;
