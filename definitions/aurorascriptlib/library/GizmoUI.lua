---@meta

--[[
	```lua
	-- Methods added in 0.6b
	userdata GizmoUI.CreateInstance( void );
	```

	**Userdata Methods:**

	```lua
	-- Methods added in 0.6b
	userdata userdata:RegisterControl( unsigned objectType, string objectName );
	bool userdata:RegisterCallback( unsigned messageType, function fnCallback );
	bool userdata:RegisterAnimationCallback( string namedFrame, function fnCallback );
	object userdata:InvokeUI( string basePath, string title, string sceneFile, [string skinFile], [table initData] );
	void userdata:Dismiss( object key );
	bool userdata:SetCommandText( unsigned commandId, string text );
	bool userdata:SetCommandEnabled( unsigned commandId, bool state );
	bool userdata:SetTimer( unsigned timerId, unsigned timerInterval );
	bool userdata:KillTimer( unsigned timerId );
	bool userdata:PlayTimeline( string startFrame, string initialFrame, string endFrame, bool recurse, bool loop );
	void userdata:Notify( string message, DWORD notifyType );
	table userdata:ShowMessagebox( unsigned identifier, string title, string prompt, string button1text, [string ...]);
	table userdata:ShowPasscode( unsigned identifier, string title, string prompt, DWORD permissionFlag );
	table userdata:ShowKeyboard( unsigned identifier, string title, string prompt, string default, DWORD flags );
	-- Methods added in 0.7b
	bool userdata:SetXLScene( bool enable );
	```

	static const luaL_Reg l_gizmoMethods[] = {
		// Methods added in 0.6b
		{ "RegisterCallback",			l_gizmoRegisterCallback },
		{ "RegisterAnimationCallback",	l_gizmoRegisterAnimationCallback },
		{ "RegisterControl",			l_gizmoRegisterControl },
		{ "InvokeUI",					l_gizmoInvokeUI },
		{ "Dismiss",					l_gizmoDismiss },
		{ "SetCommandText",				l_gizmoSetCommandText },
		{ "SetCommandEnabled",			l_gizmoSetCommandEnabled },
		{ "SetTimer",					l_gizmoSetTimer },
		{ "KillTimer",					l_gizmoKillTimer },
		{ "PlayTimeline",				l_gizmoPlayTimeline },
		{ "ShowKeyboard",				l_gizmoShowKeyboard },
		{ "ShowMessagebox",				l_gizmoShowMessagebox },
		{ "ShowPasscode",				l_gizmoShowPasscode },
		{ "Notify",						l_gizmoNotify },
		// Methods added in 0.7b
		{ "SetXLScene",					l_gizmoSetXLScene },
		{ nullptr,						nullptr }
	};
	static const luaL_Reg l_gizmouiMethods[] = {
		// Methods added in 0.6b
		{ "CreateInstance",			l_gizmouiCreateInstance },
		{ nullptr,					nullptr}
	};
]]
