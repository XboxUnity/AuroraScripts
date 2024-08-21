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
-- global functions
function print(message: string)
function tprint(table: table)
function trace(message: any)
function stackdump(): integer
function enum(enumTable: EnumTable): EnumTable
function wait(milliseconds: unsigned)
function tounsigned(value: integer): unsigned

-- global objects
GameListFilterCategories
GameListSorters
GameListSubtitles
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
-- class methods
Aurora.GetDashVersion(): VersionData
Aurora.GetSkinVersion(): VersionData
Aurora.GetFSPluginVersion(): VersionData
Aurora.GetNovaVersion(): VersionData ---@deprecated 0.7b
Aurora.HasInternetConnection(): boolean
Aurora.GetIPAddress(): string
Aurora.GetMACAddress(): string
Aurora.GetTime(): TimeInfo
Aurora.GetDate(): DateInfo
Aurora.GetTemperatures(): TemperatureInfo
Aurora.GetMemoryInfo(): MemoryInfo
Aurora.GetCurrentSkin(): SkinInfo
Aurora.GetCurrentLanguage(): LanguagePackInfo
Aurora.GetDVDTrayState(): SMCTrayState
Aurora.OpenDVDTray()
Aurora.CloseDVDTray()
Aurora.Restart()
Aurora.Reboot()
Aurora.Shutdown()
Aurora.Sha1Hash(input: string): string
Aurora.Md5Hash(input: string): string
Aurora.Crc32Hash(input: string): string
Aurora.Sha1HashFile(filePath: string): string|nil
Aurora.Md5HashFile(filePath: string): string|nil
Aurora.Crc32HashFile(filePath: string): string|nil
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
-- class methods
IniFile.LoadFile(filePath: string): userdata|nil
IniFile.LoadString(fileData: string): userdata|nil

-- userdata methods
userdata:ReadValue(section: string, key: string, default: string): string
userdata:WriteValue(section: string, key: string, value: string): boolean
userdata:GetAllSections(): table|nil
userdata:GetAllKeys(section: string): table|nil
userdata:GetSection(section: string): table|nil
```

##### Kernel

```lua
-- class methods
Kernel.GetVersion()
Kernel.GetConsoleTiltState(): TiltState
Kernel.GetCPUKey(): string|nil
Kernel.GetDVDKey(): string|nil
Kernel.GetMotherboardType(): MoboType
Kernel.GetConsoleType(): ConsoleType
Kernel.GetConsoleId(): string
Kernel.GetSerialNumber(): string
Kernel.GetCPUTempThreshold(): unsigned|nil
Kernel.GetGPUTempThreshold(): unsigned|nil
Kernel.GetEDRAMTempThreshold(): unsigned|nil
Kernel.SetCPUTempThreshold(threshold: unsigned): boolean
Kernel.SetGPUTempThreshold(threshold: unsigned): boolean
Kernel.SetEDRAMTempThreshold(threshold: unsigned): boolean
Kernel.SetFanSpeed(fanSpeed: unsigned): boolean
Kernel.SetDate(year: unsigned, month: unsigned, day: unsigned): boolean
Kernel.SetTime(hour: unsigned, [minute: unsigned], [second: unsigned], [millisecond: unsigned]): boolean
Kernel.RebootSMCRoutine()
```

##### Profile

```lua
-- class methods
Profile.GetXUID(playerIndex: integer): string
Profile.GetGamerTag(playerIndex: integer): string
Profile.GetGamerScore(playerIndex: integer): integer
Profile.GetTitleAchievement(playerIndex: integer, titleId: integer): AchievementInfo|0|-1
Profile.EnumerateProfiles(): ProfileInfo[] ---@since 0.7b
Profile.GetProfilePicture(xuid: string, path: string): boolean ---@since 0.7b
Profile.Login(playerIndex: integer, xuid: string): boolean ---@since 0.7b
Profile.Logout(playerIndex: integer): boolean ---@since 0.7b
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
-- class methods
Sql.Execute(query: string): boolean
Sql.ExecuteFetchRows(query: string): SqlResultSet|nil
```

##### Thread

```lua
-- class methods
Thread.Sleep(ms: unsigned)
```

##### ZipFile

```lua
-- class methods
ZipFile.OpenFile(filePath: string, [createIfNotExist: boolean]): userdata|nil

-- userdata methods
userdata:Extract(destDir: string): boolean
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
