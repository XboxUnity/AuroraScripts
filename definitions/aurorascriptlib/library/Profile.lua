---@meta

--[[
	```lua
	-- Methods added in 0.6b
	string Profile.GetXUID( unsigned playerIndex );
	string Profile.GetGamerTag( unsigned playerIndex );
	unsigned Profile.GetGamerScore( unsigned playerIndex );
	table Profile.GetTitleAchievement( unsigned playerIndex, unsigned titleId );
	```


	static const luaL_Reg g_profileLibrary[] = {
		// Methods added in 0.6b
		{"GetXUID",             l_profileGetXUID},             // std::string Profile.GetXUID( unsigned playerIndex );
		{"GetGamerTag",         l_profileGetGamerTag},         // std::string Profile.GetGamerTag( unsigned playerIndex );
		{"GetGamerScore",       l_profileGetGamerScore},       // unsigned Profile.GetGamerScore( unsigned playerIndex );
		{"GetTitleAchievement", l_profileGetTitleAchievement}, // table Profile.GetTitleAchievement( unsigned playerIndex, unsigned titleId );
		// Methods added in 0.7b
		{"EnumerateProfiles",   l_profileEnumerateProfiles},   // table Profile.EnumerateProfiles( void );
		{"GetProfilePicture",   l_profileGetProfilePicture},   // bool Profile.GetProfilePicture( std::string xuid );
		{"Login",               l_profileLogin},               // bool Profile.Login( unsigned playerIndex, std::string xuid );
		{"Logout",              l_profileLogout},              // bool Profile.Logout( unsigned playerIndex );
		{nullptr,					nullptr}
	};
]]
