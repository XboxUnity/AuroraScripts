scriptTitle = "Utility Scripts Unit Test"
scriptAuthor = "Phoenix"
scriptVersion = 0.1
scriptDescription = "It's our unit test!"
-- Request all libraries to be loaded even if we don't use them here...
scriptPermissions = { "http", "content", "filesystem", "settings", "sql", "kernel" }

require("MenuSystem") -- For our menu...
require("HttpTest") -- For HTTP tests
require("ContentTest") -- For Content tests
require("FileSystemTest") -- For FileSystem tests
require("SettingsTest") -- For Settings tests
require("SQLTests") -- For SQL tests
require("KernelTest") -- For Kernel tests
require("AuroraTest") -- for Aurora tests
require("IniTest") -- For Ini tests
require("ProfileTest") -- For Profile tests
require("ThreadTest") -- For Thread tests
require("XboxFileTest") -- For XboxFile tests
require("ZipTest") -- For Zip tests

-- The script entry point
function main()
	initMenu();
	local ret, _, canceled = Menu.ShowMainMenu();
	local tests = 12;
	if not canceled then
		if ret == 0 or ret == -1 then
			HttpTest();
			setProgress(0, tests, "HTTP");
		end
		if ret == 1 or ret == -1 then
			ContentTest();
			setProgress(1, tests, "Content");
		end
		if ret == 2 or ret == -1 then
			FileSystemTest();
			setProgress(2, tests, "FileSystem");
		end
		if ret == 3 or ret == -1 then
			SettingsTest();
			setProgress(3, tests, "Settings");
		end
		if ret == 4 or ret == -1 then
			SQLTest();
			setProgress(4, tests, "SQL");
		end
		if ret == 5 or ret == -1 then
			KernelTest();
			setProgress(5, tests, "Kernel");
		end
		if ret == 6 or ret == -1 then
			AuroraTest();
			setProgress(6, tests, "Aurora");
		end
		if ret == 7 or ret == -1 then
			IniTest();
			setProgress(7, tests, "Ini");
		end
		if ret == 8 or ret == -1 then
			ProfileTest();
			setProgress(8, tests, "Profile");
		end
		if ret == 9 or ret == -1 then
			ThreadTest();
			setProgress(9, tests, "Thread");
		end
		if ret == 10 or ret == -1 then
			XboxFileTest();
			setProgress(10, tests, "XboxFile");
		end
		if ret == 11 or ret == -1 then
			ZipTest();
			setProgress(11, tests, "Zip");
		end
		if ret == 12 or ret == -1 then
			-- TODO: Test Aurora UI
			setProgress(12, tests, "AuroraUI");
		end
	end
end

function setProgress(current, max, name)
	Script.SetProgress(current, max);
	Script.SetStatus("Testing: " .. name);
end

function initMenu()
	Menu.SetTitle("Select Test To Run");
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Run ALL Tests", -1));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test HTTP", 0));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test Content", 1));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test FileSystem", 2));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test Settings", 3));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test SQL", 4));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test Kernel", 5));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test Aurora", 6));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test Ini", 7));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test Profile", 8));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test Thread", 9));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test XboxFile", 10));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test Zip", 11));
	Menu.AddMainMenuItem(Menu.MakeMenuItem("Test AuroraUI", 12));
end