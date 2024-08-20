---@meta

--[[
	```lua
	-- Methods added in 0.6b
	userdata ZipFile.OpenFile( string filePath, [bool create] );
	```

	**Userdata Methods:**

	```lua
	-- Methods added in 0.6b
	bool userdata:Extract( string destDir );
	```


	static const luaL_Reg g_zipMethods[] = {
		// Methods added in 0.6b
		{"Extract", l_zipExtract}, // bool ZipFile.Extract( userdata zipFile, std::string destDir );
		{nullptr,   nullptr}
	};
	static const luaL_Reg g_zipLibrary[] = {
		// Methods added in 0.6b
		{"OpenFile", l_zipOpenFile}, // userdata ZipFile.OpenFile( std::string filePath, [bool create] );
		{nullptr,    nullptr}
	};
]]
