---@meta

--[[
	```lua
	-- Methods added in 0.6b
	table Settings.GetSystem( [string, ...] );
	table Settings.GetUser( [string, ...] );
	table Settings.SetSystem( string name, string value, [ string, string ...] );
	table Settings.SetUser( string name, string value, [ string, string ...] );
	table Settings.GetSystemOptions( string name );
	table Settings.GetUserOptions( string name );
	table Settings.GetOptions( string name, unsigned settingType );
	```


	static const luaL_Reg g_settingsLibrary[] = {
		// Methods added in 0.6b
		{"GetSystem",				l_settingsGetSystem},			// table Settings.GetSystem( [std::string, ...] );
		{"GetUser",					l_settingsGetUser},				// table Settings.GetUser( [std::string, ...] );
		{"SetSystem",				l_settingsSetSystem},			// table Settings.SetSystem( std::string name, std::string value, [ std::string, std::string ...] );
		{"SetUser",					l_settingsSetUser},				// table Settings.SetUser( std::string name, std::string value, [ std::string, std::string ...] );
		{"GetSystemOptions",		l_settingsGetSystemOptions},	// table Settings.GetSystemOptions( std::string name );
		{"GetUserOptions",			l_settingsGetUserOptions},		// table Settings.GetUserOptions( std::string name );
		{"GetOptions",				l_settingsGetOptions},			// table Settings.GetOptions( std::string name, unsigned settingType );
		// Methods added in 0.7b
		{"GetRSSFeeds",				l_settingGetRSSFeeds},			// table Settings.GetRSSFeeds( [bool enabledOnly] );
		{"GetRSSFeedById",			l_settingGetRSSFeedById},		// table Settings.GetRSSFeedById( unsigned feedId );
		{"AddRSSFeed",				l_settingAddRSSFeed},			// unsigned Settings.AddRSSFeed( std::string url, [bool enabled] );
		{"DeleteRSSFeed",			l_settingDeleteRSSFeed},		// bool Settings.DeleteRSSFeed( unsigned feedId );
		{"UpdateRSSFeed",			l_settingUpdateRSSFeed},		// bool Settings.UpdateRSSFeed( unsigned feedId, std::string url, bool enabled );
		{nullptr,					nullptr}
	};
]]
