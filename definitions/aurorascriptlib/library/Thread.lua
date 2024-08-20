---@meta

--[[
	```lua
	-- Methods added in 0.6b
	void Thread.Sleep( unsigned );
	```


	static const luaL_Reg g_threadLibrary[] = {
		// Methods added in 0.6b
		{"Sleep",        l_threadSleep}, // void Thread.Sleep( unsigned );
		{nullptr,        nullptr}
	};
]]
