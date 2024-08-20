---@meta

--[[
	```lua
	-- Methods added in 0.6b
	table Content.GetInfo( DWORD contentId );
	bool Content.SetTitle( DWORD contentId, string title );
	bool Content.SetDescription( DWORD contentId, string description );
	bool Content.SetDeveloper( DWORD contentId, string developer );
	bool Content.SetPublisher( DWORD contentId, string publisher );
	bool Content.SetReleaseDate( DWORD contentId, string releaseDate );
	bool Content.SetAsset( string imagePath, enum assetType, [DWORD screenshotIndex]);
	table Content.FindContent( DWORD titleId, [string searchText]);
	```


	static const luaL_Reg l_contentLibrary[] = {
		// Methods added in 0.6b
		{"GetInfo",        l_contentGetInfo },        // table Content.GetInfo( DWORD contentId );
		{"SetTitle",       l_contentSetTitle },       // bool Content.SetTitle( DWORD contentId, std::string title );
		{"SetDescription", l_contentSetDescription }, // bool Content.SetDescription( DWORD contentId, std::string description );
		{"SetDeveloper",   l_contentSetDeveloper },   // bool Content.SetDeveloper( DWORD contentId, std::string developer );
		{"SetPublisher",   l_contentSetPublisher },   // bool Content.SetPublisher( DWORD contentId, std::string publisher );
		{"SetReleaseDate", l_contentSetReleaseDate }, // bool Content.SetReleaseDate( DWORD contentId, std::string releaseDate );
		{"SetAsset",       l_contentSetAsset },       // bool Content.SetAsset( std::string imagePath, enum assetType, [DWORD screenshotIndex]);
		{"FindContent",    l_contentFindContent },    // table Content.FindContent( DWORD titleId, [std::string searchText]);
		{"StartScan",      l_contentStartScan },      // bool Content.StartScan( void );
		{"IsScanning",     l_contentIsScanning },     // bool Content.IsScanning( void );
		{nullptr,          nullptr}
	};
]]
