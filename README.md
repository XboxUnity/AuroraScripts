# Aurora Scripts

Aurora's Lua scripting API can be used to extend the functionality of Aurora through custom community-contributed Content (Filter, Sort, and Subtitle) and Utility scripts.

**Content Scripts** - These scripts provide custom filters, sorters, or subtitle generators for game content. They are executed automatically when Aurora loads.
- **Filters** - Modify the list of games displayed in Aurora based on custom criteria.
- **Sorters** - Change the order in which games are displayed in Aurora.
- **Subtitles** - Generate custom subtitles for games displayed in Aurora.

**Utility Scripts** - These scripts provide additional functionality for Aurora, and are downloaded from the Aurora Repo Browser. They are run on-demand by the user with their own UI.

## Contributing

Aurora Scripts are a community effort that help enhance the functionality and versatility of Aurora for all users. To ensure a smooth integration of your script into Aurora's ecosystem, review the script requirements below.

### Script Metadata

Each script must include the following metadata at the beginning of the main script file, defined as global variables.

**Content Scripts:**

```lua
ContentScriptMeta = {
    Title       = "Cool Factor Filter",
    Author      = "Stelio Kontos",
    Description = "Filters games based on their cool factor",
}
```

**Utility Scripts:**

```lua
scriptTitle = "Rick Roll"
scriptAuthor = "Stelio Kontos"
scriptVersion = 1
scriptDescription = "Randomly plays the Stelio Kontos theme song when Aurora starts"
scriptIcon = "icon\\icon.xur" -- or .png
scriptPermissions = { "http", "filesystem" } -- if using modules requiring permissions
```

### Script Permissions

Some modules must be explicitly enabled in the script's `scriptPermissions` metadata in order to be loaded at runtime and be called by the script. Modules requiring permissions are:

- Content
- FileSystem
- Http
- Kernel
- Settings
- Sql

Example:

```lua
scriptPermissions = { "http", "filesystem" } -- case-insensitive
```

## API Reference

Aurora's scripting library API exposes several [global objects and functions](definitions/aurorascriptlib/library/Globals.lua), and includes numerous feature-rich modules designed to extend the functionality of custom scripts by interfacing with Aurora's UI, filesystem, and system internals.

The included modules are available for use in all Content and Utility Scripts, and are preloaded into the Lua execution environment at runtime, eliminating the need to `require` them in your script.

Library documentation is provided as [LuaDoc](https://luals.github.io/wiki/annotations/) annotations, allowing for intellisense support and type checking when used in conjunction with the VS Code extension [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) by sumneko.

Note that these annotations are a work in progress; contributions through pull requests are welcome.

### Library Documentation

- [Global Functions](#global-functions) • [module definitions](definitions/aurorascriptlib/Globals.lua)
- [Library Modules](#library-modules)
  - [Script](#script) • [module definitions](definitions/aurorascriptlib/library/Script.lua)
  - [Aurora](#aurora) • [module definitions](definitions/aurorascriptlib/library/Aurora.lua)
  - [Content](#content) • [module definitions](definitions/aurorascriptlib/library/Content.lua)*
  - [Dvd](#dvd) • [module definitions](definitions/aurorascriptlib/library/Dvd.lua)
  - [FileSystem](#filesystem) • [module definitions](definitions/aurorascriptlib/library/FileSystem.lua)*
  - [Http](#http) • [module definitions](definitions/aurorascriptlib/library/Http.lua)*
  - [IniFile](#inifile) • [module definitions](definitions/aurorascriptlib/library/IniFile.lua)
  - [Kernel](#kernel) • [module definitions](definitions/aurorascriptlib/library/Kernel.lua)*
  - [Profile](#profile) • [module definitions](definitions/aurorascriptlib/library/Profile.lua)
  - [Settings](#settings) • [module definitions](definitions/aurorascriptlib/library/Settings.lua)*
  - [Sql](#sql) • [module definitions](definitions/aurorascriptlib/library/Sql.lua)*
  - [Thread](#thread) • [module definitions](definitions/aurorascriptlib/library/Thread.lua)
  - [ZipFile](#zipfile) • [module definitions](definitions/aurorascriptlib/library/ZipFile.lua)
  - [GizmoUI](#gizmoui) • [module definitions](definitions/aurorascriptlib/library/GizmoUI.lua)

*Requires script permissions.

#### Global Functions

```lua
void print( string val );
void tprint( table val );
int trace( string val );
int stackdump( void );
table enum( array val );
void wait( unsigned val );
unsigned tounsigned( int val );
```

#### Library Modules

##### Script

```lua
string Script.GetBasePath( void );
bool Script.FileExists( string relativePath );
void Script.CreateDirectory( string relativePath );
bool Script.IsCanceled( void );
unsigned Script.GetProgress( void );
string Script.GetStatus( void );
void Script.SetProgress( unsigned val );
void Script.SetStatus( string text );
void Script.SetRefreshListOnExit( bool refreshList );
void Script.ShowNotification( string message, DWORD notifyType );
table Script.ShowMessageBox( string title, string prompt, string button1text, [string ...]);
table Script.ShowPasscode( string title, string prompt, DWORD permissionFlag );
table Script.ShowKeyboard( string title, string prompt, string default, [DWORD flags] );
table Script.ShowPopupList( string title, string emptyList, table listContent );
table Script.ShowFilebrowser( string basePath, string selectedItem, [DWORD flags] );
```

##### Aurora

```lua
table Aurora.GetDashVersion( void );
table Aurora.GetSkinVersion( void );
table Aurora.GetFSPluginVersion( void );
--table Aurora.GetNovaVersion( void ); ---@deprecated 0.7b
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

##### Content

```lua
table Content.GetInfo( DWORD contentId );
bool Content.SetTitle( DWORD contentId, string title );
bool Content.SetDescription( DWORD contentId, string description );
bool Content.SetDeveloper( DWORD contentId, string developer );
bool Content.SetPublisher( DWORD contentId, string publisher );
bool Content.SetReleaseDate( DWORD contentId, string releaseDate );
bool Content.SetAsset( string imagePath, enum assetType, [DWORD screenshotIndex]);
table Content.FindContent( DWORD titleId, [string searchText]);
bool Content.StartScan( void );
bool Content.IsScanning( void );
```

##### Dvd

```lua
unsigned Dvd.GetTrayState( void ); ---@since 0.7b
unsigned Dvd.GetMediaType( void ); ---@since 0.7b
bool Dvd.OpenTray( void ); ---@since 0.7b
bool Dvd.CloseTray( void ); ---@since 0.7b
```

##### FileSystem

```lua
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
number FileSystem.GetPartitionSize( string driveName ); ---@since 0.7b
number FileSystem.GetPartitionUsedSpace( string driveName ); ---@since 0.7b
number FileSystem.GetPartitionFreeSpace( string driveName ); ---@since 0.7b
```

##### Http

```lua
table Http.Get( string url, [string relativeFilePath] );
table Http.Post( string url, table postvars, [string relativeFilePath] );
string Http.UrlEncode( string input );
string Http.UrlDecode( string input );
table Http.GetEx( string url, function progressRoutine, [string relativeFilePath] ); ---@since 0.7b
table Http.PostEx( string url, table postvars, function progressRoutine, [string relativeFilePath] ); ---@since 0.7b
```

##### IniFile

```lua
userdata IniFile.LoadFile( string relativeFilePath );
userdata IniFile.LoadString( string fileData );
```

**Userdata Methods:**

```lua
string userdata:ReadValue( string section, string key, string default );
bool userdata:WriteValue( string section, string key, string value );
table userdata:GetAllSections( void );
table userdata:GetAllKeys( string section );
table userdata:GetSection( string section );
```

##### Kernel

```lua
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
bool Kernel.SetCPUTempThreshold( unsigned threshold );
bool Kernel.SetGPUTempThreshold( unsigned threshold );
bool Kernel.SetEDRAMTempThreshold( unsigned threshold );
bool Kernel.SetFanSpeed( unsigned fanSpeed );
void Kernel.RebootSMCRoutine( void );
bool Kernel.SetDate(unsigned year, unsigned month, unsigned day);
bool Kernel.SetTime(unsigned hour, [unsigned minute, unsigned second, unsigned millisecond]);
```

##### Profile

```lua
string Profile.GetXUID( unsigned playerIndex );
string Profile.GetGamerTag( unsigned playerIndex );
unsigned Profile.GetGamerScore( unsigned playerIndex );
table Profile.GetTitleAchievement( unsigned playerIndex, unsigned titleId );
table Profile.EnumerateProfiles( void ); ---@since 0.7b
bool Profile.GetProfilePicture( string xuid ); ---@since 0.7b
bool Profile.Login( unsigned playerIndex, string xuid ); ---@since 0.7b
bool Profile.Logout( unsigned playerIndex ); ---@since 0.7b
```

##### Settings

```lua
table Settings.GetSystem( [string, ...] );
table Settings.GetUser( [string, ...] );
table Settings.SetSystem( string name, string value, [ string, string ...] );
table Settings.SetUser( string name, string value, [ string, string ...] );
table Settings.GetSystemOptions( string name );
table Settings.GetUserOptions( string name );
table Settings.GetOptions( string name, unsigned settingType );
table Settings.GetRSSFeeds( [bool enabledOnly] ); ---@since 0.7b
table Settings.GetRSSFeedById( unsigned feedId ); ---@since 0.7b
unsigned Settings.AddRSSFeed( string url, [bool enabled] ); ---@since 0.7b
bool Settings.DeleteRSSFeed( unsigned feedId ); ---@since 0.7b
bool Settings.UpdateRSSFeed( unsigned feedId, string url, bool enabled ); ---@since 0.7b
```

##### Sql

```lua
bool Sql.Execute( string query );
table Sql.ExecuteFetchRows( string query );
```

##### Thread

This whole module is just a placeholder for a single method.

[View module definitions](definitions/aurorascriptlib/library/Thread.lua)

```lua
-- class methods
Thread.Sleep(ms: unsigned)
```

##### ZipFile

```lua
userdata ZipFile.OpenFile( string filePath, [bool create] );
```

**Userdata Methods:**

```lua
bool userdata:Extract( string destDir );
```

##### GizmoUI

```lua
userdata GizmoUI.CreateInstance( void );
```

**Userdata Methods:**

```lua
userdata userdata:RegisterControl( unsigned objectType, string objectName );
bool userdata:RegisterCallback( unsigned messageType, function fnCallback );
bool userdata:RegisterAnimationCallback( string namedFrame, function fnCallback );
object userdata:InvokeUI( string basePath, string title, string sceneFile, [string skinFile], [table initData] );
void userdata:Dismiss( object key );
bool userdata:SetXLScene( bool enable ); ---@since 0.7b
bool userdata:SetCommandText( unsigned commandId, string text );
bool userdata:SetCommandEnabled( unsigned commandId, bool state );
bool userdata:SetTimer( unsigned timerId, unsigned timerInterval );
bool userdata:KillTimer( unsigned timerId );
bool userdata:PlayTimeline( string startFrame, string initialFrame, string endFrame, bool recurse, bool loop );
void userdata:Notify( string message, DWORD notifyType );
table userdata:ShowMessagebox( unsigned identifier, string title, string prompt, string button1text, [string ...]);
table userdata:ShowPasscode( unsigned identifier, string title, string prompt, DWORD permissionFlag );
table userdata:ShowKeyboard( unsigned identifier, string title, string prompt, string default, DWORD flags );
```

### XUI Object Tree

- [XUI](#xui)
  - [XuiObject](#xuiobject)
    - [XuiElement](#xuielement--xuiobject)
      - [XuiText](#xuitext--xuielement--xuiobject)
      - [XuiImage](#xuiimage--xuielement--xuiobject)
      - [XuiControl](#xuicontrol--xuielement--xuiobject)
        - [XuiButton](#xuibutton--xuicontrol--xuielement--xuiobject)
        - [XuiRadioButton](#xuiradiobutton--xuicontrol--xuielement--xuiobject)
        - [XuiRadioGroup](#xuiradiogroup--xuicontrol--xuielement--xuiobject)
        - [XuiLabel](#xuilabel--xuicontrol--xuielement--xuiobject)
        - [XuiEdit](#xuiedit--xuicontrol--xuielement--xuiobject)
        - [XuiList](#xuilist--xuicontrol--xuielement--xuiobject)
        - [XuiProgressBar](#xuiprogressbar--xuicontrol--xuielement--xuiobject)
        - [XuiSlider](#xuislider--xuicontrol--xuielement--xuiobject)
        - [XuiCheckbox](#xuicheckbox--xuicontrol--xuielement--xuiobject)
        - [XuiScene](#xuiscene--xuicontrol--xuielement--xuiobject)
          - [XuiTabScene](#xuitabscene--xuiscene--xuicontrol--xuielement--xuiobject)

#### XuiObject

    call
    typeOf

#### XuiElement : XuiObject

    GetBounds
    GetId
    PlayTimeline
    SetPosition
    SetOpacity
    SetShow
    GetPosition
    GetOpacity
    IsShown

#### XuiText : XuiElement : XuiObject

    GetText
    MeasureText
    SetText

#### XuiImage : XuiElement : XuiObject

    GetImagePath
    SetImagePath

#### XuiControl : XuiElement : XuiObject

    GetImagePath
    IsBackButton
    IsEnabled
    IsNavButton
    PlayVisualRange
    SetEnable
    SetImagePath
    SetText

#### XuiButton : XuiControl : XuiElement : XuiObject

    (none)

#### XuiRadioButton : XuiControl : XuiElement : XuiObject

    (none)

#### XuiRadioGroup : XuiControl : XuiElement : XuiObject

    GetCurSel
    SetCurSel

#### XuiLabel : XuiControl : XuiElement : XuiObject

    (none)

#### XuiEdit : XuiControl : XuiElement : XuiObject

    DeleteText
    GetCaretPosition
    GetLineCount
    GetLineIndex
    GetMaxVisibleLineCount
    GetReadOnly
    GetTextLimit
    GetTopLine
    GetVisibleLineCount
    GetVSmoothScrollEnabled
    InsertText
    SetCaretPosition
    SetTextLimit
    SetTopLine

#### XuiList : XuiControl : XuiElement : XuiObject

    DeleteItems
    GetCurSel
    GetItemCheck
    GetItemCount
    GetMaxVisibleLineCount
    GetMaxLinesItemCount
    GetText
    GetTopItem
    GetVisibleItemCount
    InsertItems
    IsItemChecked
    IsItemEnabled
    IsItemVisible
    SetCurSel
    SetCurSelVisible
    SetImagePath
    SetItemCheck
    SetItemEnable
    SetText
    SetTopItem

#### XuiProgressBar : XuiControl : XuiElement : XuiObject

    GetRange
    GetValue
    SetRange
    SetValue

#### XuiSlider : XuiControl : XuiElement : XuiObject

    GetAccel
    GetRange
    GetStep
    GetValue
    SetAccel
    SetRange
    SetStep
    SetValue

#### XuiCheckbox : XuiControl : XuiElement : XuiObject

    IsChecked
    SetCheck

#### XuiScene : XuiControl : XuiElement : XuiObject

    (none)

#### XuiTabScene : XuiScene : XuiControl : XuiElement : XuiObject

    CanUserTab
    EnableTabbing
    GetCount
    GetCurrentTab
    Goto
    GotoNext
    GotoPrev
