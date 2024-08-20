---@meta

--[[
	```lua
	-- Methods added in 0.6b
	table Kernel.GetVersion( void );
	unsigned Kernel.GetConsoleTiltState( void );
	string Kernel.GetCPUKey( void );
	string Kernel.GetDVDKey( void );
	string Kernel.GetMotherboardType( void );
	string Kernel.GetConsoleType( void );
	string Kernel.GetConsoleId( void );
	string Kernel.GetSerialNumber( void );
	unsigned Kernel.GetCPUTempThreshold( void );
	unsigned Kernel.GetGPUTempThreshold( void );
	unsigned Kernel.GetEDRAMTempThreshold( void );
	bool Kernel.SetFanSpeed( unsigned fanSpeed );
	bool Kernel.SetCPUTempThreshold( unsigned threshold );
	bool Kernel.SetGPUTempThreshold( unsigned threshold );
	bool Kernel.SetEDRAMTempThreshold( unsigned threshold );
	void Kernel.RebootSMCRoutine( void );
	bool Kernel.SetDate(unsigned year, unsigned month, unsigned day);
	bool Kernel.SetTime(unsigned hour, [unsigned minute, unsigned second, unsigned millisecond]);
	```


	static const luaL_Reg g_kernelLibrary[] = {
		// Methods added in 0.6b
		{"GetVersion",				l_kernelGetVersion},			// table Kernel.GetVersion( void );
		{"GetConsoleTiltState",		l_kernelGetConsoleTiltState},	// unsigned Kernel.GetConsoleTiltState( void );
		{"GetCPUKey",				l_kernelGetCPUKey},				// std::string Kernel.GetCPUKey( void );
		{"GetDVDKey",				l_kernelGetDVDKey},				// std::string Kernel.GetDVDKey( void );
		{"GetMotherboardType",		l_kernelGetMotherboardType},	// std::string Kernel.GetMotherboardType( void );
		{"GetConsoleType",			l_kernelGetConsoleType},		// std::string Kernel.GetConsoleType( void );
		{"GetConsoleId",			l_kernelGetConsoleId},			// std::string Kernel.GetConsoleId( void );
		{"GetSerialNumber",			l_kernelGetSerialNumber},		// std::string Kernel.GetSerialNumber( void );
		{"GetCPUTempThreshold",		l_kernelGetCPUTempThreshold},	// unsigned Kernel.GetCPUTempThreshold( void );
		{"GetGPUTempThreshold",		l_kernelGetGPUTempThreshold},	// unsigned Kernel.GetGPUTempThreshold( void );
		{"GetEDRAMTempThreshold",	l_kernelGetEDRAMTempThreshold},	// unsigned Kernel.GetEDRAMTempThreshold( void );
		{"SetFanSpeed",				l_kernelSetFanSpeed},			// bool Kernel.SetFanSpeed( unsigned fanSpeed );
		{"SetCPUTempThreshold",		l_kernelSetCPUTempThreshold},	// bool Kernel.SetCPUTempThreshold( unsigned threshold );
		{"SetGPUTempThreshold",		l_kernelSetGPUTempThreshold},	// bool Kernel.SetGPUTempThreshold( unsigned threshold );
		{"SetEDRAMTempThreshold",	l_kernelSetEDRAMTempThreshold},	// bool Kernel.SetEDRAMTempThreshold( unsigned threshold );
		{"RebootSMCRoutine",		l_kernelRebootSMCRoutine},		// void Kernel.RebootSMCRoutine( void );
		{"SetDate",					l_kernelSetDate},				// bool Kernel.SetDate(unsigned year, unsigned month, unsigned day);
		{"SetTime",					l_kernelSetTime},				// bool Kernel.SetTime(unsigned hour, [unsigned minute, unsigned second, unsigned millisecond]);
		{nullptr,					nullptr}
	};
]]
