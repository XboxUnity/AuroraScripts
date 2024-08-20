---@meta

--[[
	```lua
	-- Methods added in 0.7b
	unsigned Dvd.GetTrayState( void );
	unsigned Dvd.GetMediaType( void );
	bool Dvd.OpenTray( void );
	bool Dvd.CloseTray( void );
	```

	static const luaL_Reg g_dvdLibrary[] = {
		// Methods added in 0.7b
		{"GetTrayState", l_dvdGetTrayState}, // unsigned Dvd.GetTrayState( void );
		{"GetMediaType", l_dvdGetMediaType}, // unsigned Dvd.GetMediaType( void );
		{"OpenTray",     l_dvdOpenTray},     // boolean Dvd.OpenTray( void );
		{"CloseTray",    l_dvdCloseTray},    // boolean Dvd.CloseTray( void );
		{nullptr,        nullptr}
	};
]]
