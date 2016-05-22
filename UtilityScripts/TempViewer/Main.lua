scriptTitle = "Temperature Viewer"
scriptAuthor = "Phoenix"
scriptVersion = 1
scriptDescription = "This script displays the current console temperatures in both Celsius and Fahrenheit"
-- Request all libraries to be loaded even if we don't use them here...
--scriptPermissions = { "http", "content", "filesystem", "settings", "sql", "kernel" }

local function toFahrenheit(c)
    return c * 9 / 5 + 32
end

-- The script entry point
function main()
	local temps = Aurora.GetTemperatures();
	local msg = "CPU: " .. string.format("%.2f", temps["CPU"]) .. "°C / " .. string.format("%.2f", toFahrenheit(temps["CPU"])) .. "°F\n";
	msg = msg .. "GPU: " .. string.format("%.2f", temps["GPU"]) .. "°C / " .. string.format("%.2f", toFahrenheit(temps["GPU"])) .. "°F\n";
	msg = msg .. "RAM: " .. string.format("%.2f", temps["RAM"]) .. "°C / " .. string.format("%.2f", toFahrenheit(temps["RAM"])) .. "°F\n";
	msg = msg .. "CPU: " .. string.format("%.2f", temps["BRD"]) .. "°C / " .. string.format("%.2f", toFahrenheit(temps["BRD"])) .. "°F\n";
	Script.ShowMessageBox("Current Temperatures", msg, "OK");
end