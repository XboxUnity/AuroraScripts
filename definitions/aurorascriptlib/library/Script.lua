---@meta

--[[
	```lua
	-- Methods added in 0.6b
	string Script.GetBasePath( void );
	void Script.FileExists( string relativePath );
	void Script.CreateDirectory( string relativePath );
	bool Script.IsCanceled( void );
	unsigned Script.GetProgress( void );
	string Script.GetStatus( void );
	void Script.SetProgress( unsigned val );
	void Script.SetStatus( string text );
	void Script.SetRefreshListOnExit( bool refreshList );
	void Script.ShowNotification( string message, DWORD type );
	table Script.ShowMessageBox( string title, string prompt, string button1text, [string ...]);
	table Script.ShowPasscode( string title, string prompt, DWORD permissionFlag );
	table Script.ShowKeyboard( string title, string prompt, string default, [DWORD flags] );
	table Script.ShowPopupList( string title, string emptyList, table listContent );
	table Script.ShowFilebrowser( string basePath, string selectedItem, [DWORD flags] );
	```

	// Methods added in 0.6b
	lua_pushcfunction(lua, ScriptRunner_GetBasePath); lua_setfield(lua, -2, "GetBasePath");
	lua_pushcfunction(lua, l_scriptFileExists); lua_setfield(lua, -2, "FileExists");                       // boolean Script.FileExists( string relativePath );
	lua_pushcfunction(lua, l_scriptRecursiveMkDir); lua_setfield(lua, -2, "CreateDirectory");              // void Script.CreateDirectory( string relativePath );
	lua_pushcfunction(lua, ScriptRunner_IsCanceled); lua_setfield(lua, -2, "IsCanceled");
	lua_pushcfunction(lua, ScriptRunner_GetProgress); lua_setfield(lua, -2, "GetProgress");
	lua_pushcfunction(lua, ScriptRunner_GetStatus); lua_setfield(lua, -2, "GetStatus");
	lua_pushcfunction(lua, ScriptRunner_GetCanCancel); lua_setfield(lua, -2, "IsCancelEnabled");
	lua_pushcfunction(lua, ScriptRunner_SetProgress); lua_setfield(lua, -2, "SetProgress");
	lua_pushcfunction(lua, ScriptRunner_SetStatus); lua_setfield(lua, -2, "SetStatus");
	lua_pushcfunction(lua, ScriptRunner_SetCanCancel); lua_setfield(lua, -2, "SetCancelEnable");
	lua_pushcfunction(lua, ScriptRunner_SetRefreshListOnExit); lua_setfield(lua, -2, "RefreshListOnExit"); // void Script.SetRefreshListOnExit( bool refreshList );
	lua_pushcfunction(lua, l_scriptShowNotification); lua_setfield(lua, -2, "ShowNotification");           // void Script.ShowNotification( string message, [DWORD type] );
	lua_pushcfunction(lua, l_scriptShowMessageBox); lua_setfield(lua, -2, "ShowMessageBox");               // table Script.ShowMessageBox( string title, string prompt, string button1text, [string ...]);
	lua_pushcfunction(lua, l_scriptShowPasscode); lua_setfield(lua, -2, "ShowPasscode");                   // table Script.ShowPasscode( string title, string prompt, DWORD permissionFlag );
	lua_pushcfunction(lua, l_scriptShowPasscodeEx); lua_setfield(lua, -2, "ShowPasscodeEx");               // table Script.ShowPasscodeEx( string title, string prompt );
	lua_pushcfunction(lua, l_scriptShowKeyboard); lua_setfield(lua, -2, "ShowKeyboard");                   // table Script.ShowKeyboard( string title, string prompt, string default, [DWORD flags] );
	lua_pushcfunction(lua, l_scriptShowPopupList); lua_setfield(lua, -2, "ShowPopupList");                 // table Script.ShowPopupList( string title, string emptyList, table listContent );
	lua_pushcfunction(lua, l_scriptShowFilebrowser); lua_setfield(lua, -2, "ShowFilebrowser");             // table Script.ShowFilebrowser( string basePath, string selectedItem, DWORD flags );
]]
