---@meta

--[[
    ```lua
    -- Methods added in 0.6b
    table Aurora.GetDashVersion( void );
    table Aurora.GetSkinVersion( void );
    table Aurora.GetFSPluginVersion( void );
    --table Aurora.GetNovaVersion( void );
    bool Aurora.HasInternetConnection( void );
    string Aurora.GetIPAddress( void );
    string Aurora.GetMACAddress( void );
    table Aurora.GetTime( void );
    table Aurora.GetDate( void );
    table Aurora.GetTemperatures( void );
    table Aurora.GetMemoryInfo( void );
    table Aurora.GetCurrentSkin( void );
    table Aurora.GetCurrentLanguage( void );
    unsigned Aurora.GetDVDTrayState( void );
    void Aurora.OpenDVDTray( void );
    void Aurora.CloseDVDTray( void );
    void Aurora.Restart( void );
    void Aurora.Reboot( void );
    void Aurora.Shutdown( void );
    string Aurora.Sha1Hash( string input );
    string Aurora.Md5Hash( string input );
    string Aurora.Crc32Hash( string input );
    string Aurora.Sha1HashFile( string filePath );
    string Aurora.Md5HashFile( string filePath );
    string Aurora.Crc32HashFile( string filePath );
    ```


    static const luaL_Reg g_auroraLibrary[] = {
        // Methods added in 0.6b
        {"GetDashVersion",        l_auroraGetDashVersion},        // table Aurora.GetDashVersion( void );
        {"GetSkinVersion",        l_auroraGetSkinVersion},        // table Aurora.GetSkinVersion( void );
        {"GetFSPluginVersion",    l_auroraGetFSPluginVersion},    // table Aurora.GetFSPluginVersion( void );
    //	{"GetNovaVersion",        l_auroraGetNovaVersion},        // table Aurora.GetFSPluginVersion( void );
        {"HasInternetConnection", l_auroraHasInternetConnection}, // bool Aurora.HasInternetConnection( void );
        {"GetIPAddress",          l_auroraGetIPAddress},          // std::string Aurora.GetIPAddress( void );
        {"GetMACAddress",         l_auroraGetMACAddress},         // std::string Aurora.GetMACAddress( void );
        {"GetTime",               l_auroraGetTime},               // table Aurora.GetTime( void );
        {"GetDate",               l_auroraGetDate},               // table Aurora.GetDate( void );
        {"GetTemperatures",       l_auroraGetTemperatures},       // table Aurora.GetTemperatures( void );
        {"GetMemoryInfo",         l_auroraGetMemoryInfo},         // table Aurora.GetMemoryInfo( void );
        {"GetCurrentSkin",        l_auroraGetCurrentSkin},        // table Aurora.GetCurrentSkin( void );
        {"GetCurrentLanguage",    l_auroraGetCurrentLanguage},    // table Aurora.GetCurrentLanguage( void );
        {"OpenDVDTray",           l_auroraOpenDVDTray},           // void Aurora.OpenDVDTray( void );
        {"CloseDVDTray",          l_auroraCloseDVDTray},          // void Aurora.CloseDVDTray( void );
        {"GetDVDTrayState",       l_auroraGetDVDTrayState},       // unsigned Aurora.GetDVDTrayState( void );
        {"Restart",               l_auroraRestart},               // void Aurora.Restart( void );
        {"Reboot",                l_auroraReboot},                // void Aurora.Reboot( void );
        {"Shutdown",              l_auroraShutdown},              // void Aurora.Shutdown( void );
        {"Sha1Hash",              l_auroraSha1Hash},              // std::string Aurora.Sha1Hash( std::string input );
        {"Md5Hash",               l_auroraMd5Hash},               // std::string Aurora.Md5Hash( std::string input );
        {"Crc32Hash",             l_auroraCrc32Hash},             // std::string Aurora.Crc32Hash( std::string input );
        {"Sha1HashFile",          l_auroraSha1HashFile},          // std::string Aurora.Sha1HashFile( std::string filePath );
        {"Md5HashFile",           l_auroraMd5HashFile},           // std::string Aurora.Md5HashFile( std::string filePath );
        {"Crc32HashFile",         l_auroraCrc32HashFile},         // std::string Aurora.Crc32HashFile( std::string filePath );
        {nullptr,                 nullptr}
    };
]]
