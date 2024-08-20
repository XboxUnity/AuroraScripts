---@meta

--[[
	```lua
	-- Methods added in 0.6b
	bool FileSystem.CopyDirectory( string srcDir, string dstDir, bool overwrite, [function progressRoutine] );
	bool FileSystem.MoveDirectory( string srcDir, string dstDir, bool overwrite, [function progressRoutine] );
	bool FileSystem.DeleteDirectory( string directory );
	bool FileSystem.CreateDirectory( string directory );
	bool FileSystem.CopyFile( string srcFile, string dstFile, bool overwrite, [function progressRoutine] );
	bool FileSystem.MoveFile( string srcFile, string dstFile, bool overwrite, [function progressRoutine] );
	bool FileSystem.DeleteFile( string srcFile );
	string Filesystem.ReadFile( string srcFile );
	bool FileSystem.WriteFile( string srcFile, string buffer );
	bool FileSystem.FileExists( string path );
	unsigned FileSystem.GetFileSize( string path );
	unsigned FileSystem.GetAttributes( string path );
	table FileSystem.GetDrives( [bool contentDrivesOnly] )
	table FileSystem.GetFilesAndDirectories( string path );
	table FileSystem.GetFiles( string path );
	table FileSystem.GetDirectories( string path );
	bool FileSystem.Rename( string original, string new );
	bool FileSystem.InstallTitleFromDisc( string virtualTargetPath, bool createContentDirs, [function progressRoutine] );
	-- Methods added in 0.7b
	number FileSystem.GetPartitionSize( string driveName );
	number FileSystem.GetPartitionUsedSpace( string driveName );
	number FileSystem.GetPartitionFreeSpace( string driveName );
	```

	static const luaL_Reg l_filesystemMethods[] = {
		// Methods added in 0.6b
		{"CopyDirectory",          l_filesystemCopyDirectory },          // bool FileSystem.CopyDirectory( std::string srcDir, std::string dstDir, bool overwrite, [function progressRoutine] );
		{"MoveDirectory",          l_filesystemMoveDirectory },          // bool FileSystem.MoveDirectory( std::string srcDir, std::string dstDir, bool overwrite, [function progressRoutine] );
		{"DeleteDirectory",        l_filesystemDeleteDirectory },        // bool FileSystem.DeleteDirectory( std::string directory );
		{"CreateDirectory",        l_filesystemCreateDirectory },        // bool FileSystem.CreateDirectory( std::string directory );
		{"CopyFile",               l_filesystemCopyFile },               // bool FileSystem.CopyFile( std::string srcFile, std::string dstFile, bool overwrite, [function progressRoutine] );
		{"MoveFile",               l_filesystemMoveFile },               // bool FileSystem.MoveFile( std::string srcFile, std::string dstFile, bool overwrite, [function progressRoutine] );
		{"DeleteFile",             l_filesystemDeleteFile },             // bool FileSystem.DeleteFile( std::string srcFile );
		{"ReadFile",               l_filesystemReadFile },               // std::string Filesystem.ReadFile( std::string srcFile );
		{"WriteFile",              l_filesystemWriteFile },              // bool FileSystem.WriteFile( std::string srcFile, std::string buffer );
		{"FileExists",             l_filesystemExists },                 // bool FileSystem.FileExists( std::string path );
		{"GetFileSize",            l_filesystemGetFileSize },            // unsigned FileSystem.GetFileSize( std::string path );
		{"GetAttributes",          l_filesystemGetAttributes },          // unsigned FileSystem.GetAttributes( std::string path );
		{"GetDrives",              l_filesystemGetDrives },              // table FileSystem.GetDrives( [bool contentDrivesOnly] )
		{"GetFilesAndDirectories", l_filesystemGetFilesAndDirectories }, // table FileSystem.GetFilesAndDirectories( std::string path );
		{"GetFiles",               l_filesystemGetFiles},                // table FileSystem.GetFiles( std::string path );
		{"GetDirectories",         l_filesystemGetDirectories},          // table FileSystem.GetDirectories( std::string path );
		{"Rename",                 l_filesystemRename },                 // bool FileSystem.Rename( std::string original, std::string new );
		{"InstallTitleFromDisc",   l_filesystemInstallTitleFromDisc},    // bool FileSystem.InstallTitleFromDisc( std::string virtualTargetPath, bool createContentDirs, [function progressRoutine] );
		// Methods added in 0.7b
		{"GetPartitionSize",       l_filesystemGetPartitionSize},        // number FileSystem.GetPartitionSize( std::string driveName );
		{"GetPartitionUsedSpace",  l_filesystemGetPartitionUsedSpace},   // number FileSystem.GetPartitionUsedSpace( std::string driveName );
		{"GetPartitionFreeSpace",  l_filesystemGetPartitionFreeSpace},   // number FileSystem.GetPartitionFreeSpace( std::string driveName );
		{nullptr,		nullptr}
	};
]]
