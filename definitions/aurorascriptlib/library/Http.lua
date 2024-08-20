---@meta

--[[
	```lua
	-- Methods added in 0.6b
	table Http.Get( string url, [string outputPath] );
	table Http.Post( string url, table postvars, [string outputPath] );
	string Http.UrlEncode( string input );
	string Http.UrlDecode( string input );
	-- Methods added in 0.7b
	table Http.GetEx( string url, function progressRoutine, [string outputPath] );
	table Http.PostEx( string url, table postvars, function progressRoutine, [string outputPath] );
	```


	static const luaL_Reg g_httpLibrary[] = {
		// Methods added in 0.6b
		{"Get",       l_httpGet },       // table Http.Get( std::string url, [std::string relativeFilePath] );
		{"Post",      l_httpPost },      // table Http.Post( std::string url, table postvars, [std::string relativeFilePath] );
		{"UrlEncode", l_httpUrlEncode }, // std::string Http.UrlEncode( std::string input );
		{"UrlDecode", l_httpUrlDecode }, // std::string Http.UrlDecode( std::string input );
		// Methods added in 0.7b
		{"GetEx",     l_httpGetEx },     // table Http.GetEx( std::string url, function progressRoutine, [std::string relativeFilePath] );
		{"PostEx",    l_httpPostEx },    // table Http.PostEx( std::string url, table postvars, function progressRoutine, [std::string relativeFilePath] );
		{NULL,				NULL}
	};
]]
