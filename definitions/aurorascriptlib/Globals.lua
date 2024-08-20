---@meta

--[[
	```lua
	-- Methods added in 0.6b
	void print( string val );
	void tprint( table val );
	table enum( array val );
	void wait( unsigned val );
	unsigned tounsigned( int val );
	```


	HRESULT LuaVirtualMachine::InitGlobaFunctions() {
		// Methods added in 0.6b
		RegisterFunction(m_pState, "print", &LuaVirtualMachine::Print);
		RegisterFunction(m_pState, "tprint", &LuaVirtualMachine::TPrint);
		RegisterFunction(m_pState, "trace", &LuaVirtualMachine::Trace);
		RegisterFunction(m_pState, "stackdump", &LuaVirtualMachine::StackDump);
		RegisterFunction(m_pState, "enum", &LuaVirtualMachine::Enum);
		RegisterFunction(m_pState, "wait", &LuaVirtualMachine::Wait);
		RegisterFunction(m_pState, "tounsigned", &LuaVirtualMachine::ToUnsigned);
		return S_OK;
	}
]]
