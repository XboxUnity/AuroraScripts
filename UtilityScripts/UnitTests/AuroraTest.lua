function AuroraTest()
	print("---- Start of Aurora Test ----")
	print("GetDashVersion:");
	print(Aurora.GetDashVersion());
	print("----");
	print("GetSkinVersion:");
	print(Aurora.GetSkinVersion());
	print("----");
	print("GetFSPluginVersion:");
	print(Aurora.GetFSPluginVersion());
	print("----");
	print("GetIPAddress:")
	print(Aurora.GetIPAddress());
	print("----");
	print("GetMACAddress:");
	print(Aurora.GetMACAddress());
	print("----");
	print("GetTime:");
	print(Aurora.GetTime());
	print("----");
	print("GetDate:");
	print(Aurora.GetDate());
	print("----");
	print("GetTemperatures:");
	print(Aurora.GetTemperatures());
	print("----");
	print("GetMemoryInfo:");
	print(Aurora.GetMemoryInfo());
	print("----");
	print("GetCurrentSkin:");
	print(Aurora.GetCurrentSkin());
	print("----");
	print("GetCurrentLanguage:");
	print(Aurora.GetCurrentLanguage());
	print("----");
	print("Opening DVD Tray...");
	Aurora.OpenDVDTray();
	print("Waiting 500ms...");
	Thread.Sleep(500);
	print("----");
	print("GetDVDTrayState:");
	print(Aurora.GetDVDTrayState());
	print("----");
	print("Closing DVD Tray...");
	Aurora.CloseDVDTray();
	print("Waiting 500ms...");
	Thread.Sleep(500);
	print("----");
	print("GetDVDTrayState:");
	print(Aurora.GetDVDTrayState());
	print("----");
	print("HasInternetConnection:");
	print(Aurora.HasInternetConnection());
	print("----");
	print("Sha1Hash('test'):");
	print("A94A8FE5CCB19BA61C4C0873D391E987982FBBD3 <--- Expected");
	print(Aurora.Sha1Hash("test") .. " <--- Actual");
	print("----");
	print("Md5Hash('test'):");
	print("098F6BCD4621D373CADE4E832627B4F6 <--- Expected");
	print(Aurora.Md5Hash("test") .. " <--- Actual");
	print("----");
	print("Crc32Hash('test'):");
	print("D87F7E0C <--- Expected");
	print(Aurora.Crc32Hash("test") .. " <--- Actual");
	print("----");
	-- TODO: Implement tests for Sha1HashFile, Md5HashFile and Crc32HashFile	
	print("---- End of Aurora Test ----")
end