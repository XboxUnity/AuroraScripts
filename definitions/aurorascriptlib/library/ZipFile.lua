---@meta

--[[
	```lua
	-- Methods added in 0.6b
	userdata ZipFile.OpenFile( string relativeFilePath );
	```

	**Userdata Methods:**

	```lua
	-- Methods added in 0.6b
	bool userdata:Extract( string relativeDestDir );
	```


	static const luaL_Reg g_zipMethods[] = {
		// Methods added in 0.6b
		{"Extract", l_zipExtract}, // bool ZipFile.Extract( userdata zipFile, std::string relativeDestDir );
		{"__gc",    l_zipDestroy}, // void ZipFile.__gc( userdata zipFile );
		{nullptr,   nullptr}
	};
	static const luaL_Reg g_zipLibrary[] = {
		// Methods added in 0.6b
		{"OpenFile", l_zipOpenFile}, // userdata ZipFile.OpenFile( std::string relativeFilePath );
		{nullptr,    nullptr}
	};
]]
