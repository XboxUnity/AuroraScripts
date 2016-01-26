scriptTitle = "Console Info Viewer"
scriptAuthor = "Phoenix"
scriptVersion = 0.1
scriptDescription = "This script displays valuable information about your console"
scriptPermissions = { "kernel" }

function main()
	local ver = Kernel.GetVersion();
	local msg = "Kernel Version: " .. ver.Major .. "." .. ver.Minor .. "." .. ver.Build .. "." .. ver.Qfe .. "\n";
	msg = msg .. "Console Type: " .. Kernel.GetConsoleType() .. "\n";
	msg = msg .. "Motherboard Type: " .. Kernel.GetMotherboardType() .. "\n";
	msg = msg .. "Console Serial: " .. Kernel.GetSerialNumber() .. "\n";
	msg = msg .. "Console ID: " .. Kernel.GetConsoleId() .. "\n";
	local key = Kernel.GetDVDKey();
	if key ~= nil then
		msg = msg .. "DVDKey: " .. key .. "\n";
	else
		msg = msg .. "DVDKey: N\\A\n";
	end
	key = Kernel.GetCPUKey();
	if key ~= nil then
		msg = msg .. "CPUKey: " .. key .. "\n";
	else
		msg = msg .. "CPUKey: N\\A\n";
	end
	Script.ShowMessageBox("Console Information", msg, "OK");
end
