---@meta

--[[
	```lua
	-- Methods added in 0.6b
	userdata IniFile.LoadFile( string relativeFilePath );
	userdata IniFile.LoadString( string fileData );
	```

	**Userdata Methods:**

	```lua
	-- Methods added in 0.6b
	string userdata:ReadValue( string section, string key, string default );
	bool userdata:WriteValue( string section, string key, string value );
	table userdata:GetAllSections( void );
	table userdata:GetAllKeys( string section );
	table userdata:GetSection( string section );
	```

	static const luaL_Reg g_iniMethods[] = {
		// Methods added in 0.6b
		{"ReadValue",      l_iniReadValue },      // std::string IniFile.ReadValue( userdata iniFile, std::string section, std::string key, std::string default );
		{"WriteValue",     l_iniWriteValue },     // bool IniFile.WriteValue( userdata iniFile, std::string section, std::string key, std::string value );
		{"GetAllSections", l_iniGetAllSections }, // table IniFile.GetAllSections( userdata iniFile );
		{"GetAllKeys",     l_iniGetAllKeys },     // table IniFile.GetAllKeys( userdata iniFile, std::string section );
		{"GetSection",     l_iniGetSection },     // table IniFile.GetSection( userdata iniFile, std::string section );
		{"__gc",           l_iniDestroy },        // void IniFile.__gc( userdata iniFile );
		{NULL,             NULL}
	};
	static const luaL_Reg g_iniLibrary[] = {
		// Methods added in 0.6b
		{"LoadFile",   l_iniLoadFile },   // userdata IniFile.LoadFile( std::string relativeFilePath );
		{"LoadString", l_iniLoadString }, // userdata IniFile.LoadString( std::string fileData );
		{NULL,         NULL}
	};
]]
