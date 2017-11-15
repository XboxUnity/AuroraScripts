scriptTitle = "TULocationFix"
scriptAuthor = "Swizzy"
scriptVersion = 1
scriptIcon = "icon\\icon.png";
scriptDescription = "TU Location Fix (adds support for USB#:\\ paths for TU's) This is only needed on 0.6b and only if you didn't do a fresh install"

scriptPermissions = { "settings" }

-- Main entry point to script
function main()
	local ver = Aurora.GetDashVersion(); -- Get Aurora Version
	if ver.Major == 0 and ver.Minor == 6 then -- Check Aurora Version
		local set = Settings.GetSystem("TitleUpdateDevice"); -- Get current settings		
		if set.TitleUpdateDevice.default == set.TitleUpdateDevice.value then -- Check if it's already what it needs to be...
			Script.ShowMessageBox("ERROR", "You don't need this fix, the value is already what it should be...", "OK");
		else
			set.TitleUpdateDevice.default = string.gsub(set.TitleUpdateDevice.default, "USB", "Usb", 3); -- Update the default to be lowercase Usb#
			if set.TitleUpdateDevice.default == set.TitleUpdateDevice.value then -- Check again if it's equal...
				Script.ShowMessageBox("ERROR", "You don't need this fix, the value is already what it should be...", "OK");
			else
				local res = Settings.SetSystem("TitleUpdateDevice", set.TitleUpdateDevice.default); -- Update the setting
				-- Debug info
				print("Original:");
				print(set);
				print("Result:");
				print(res);
				-- End of Debug info
				if res.TitleUpdateDevice.success then
					Script.ShowMessageBox("Success!","Successfully updated TU Location...", "OK");
				else
					Script.ShowMessageBox("ERROR", "Failed updating the setting", "OK");
				end
			end
		end
	else
		Script.ShowMessageBox("ERROR", "This script is only compatible with Aurora 0.6B", "OK");
	end
end