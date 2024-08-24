# Aurora Scripts

Aurora's Lua scripting API can be used to extend the functionality of Aurora through custom community-contributed Content (Filter, Sort, and Subtitle) and Utility scripts. These scripts are a community effort that help enhance the functionality and versatility of Aurora for all users, and comprise two main categories:

**Content Scripts** - These scripts provide custom filters, sorters, or subtitle generators for game content. They are executed automatically when Aurora loads.
- [**Filters**](Filters/) - Modify the list of games displayed in Aurora based on custom criteria.
- [**Sorters**](Sorts/) - Change the order in which games are displayed in Aurora.
- [**Subtitles**](Subtitles/) - Generate custom subtitles for games displayed in Aurora.

[**Utility Scripts**](UtilityScripts/) - These scripts provide additional functionality within Aurora, and run in their own UI when loaded through Aurora.

All scripts included in this repository can be downloaded (and auto updated) directly from Aurora using the Aurora Repo Browser.

## Script Development

Aurora's scripting library API exposes several [global objects and functions](definitions/aurorascriptlib/library/Globals.lua), and includes numerous feature-rich [modules](definitions/aurorascriptlib/library/) designed to extend the functionality of custom Aurora scripts by interfacing with Aurora's script execution environment and UI, as well as the Xbox 360 internals.

Refer to the [module definitions README](definitions/aurorascriptlib/README.md) for a quick reference function list or to review the documentation and annotations.

For custom script development, we recommend using [Visual Studio Code](https://code.visualstudio.com/) with the [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) extension.

After forking this repository and cloning it to your local machine, open the project directory in VS Code. You will be prompted to install the recommended extensions for the project, which include the Lua Language Server for intellisense support.

If this is your first time writing a writing a script for Aurora, a good place to start is by reviewing the [Weather Script](UtilityScripts/Weather), written by Aurora developers and specifically designed to serve as a fully functional example "how-to" sample script. The script is heavily commented, follows idiomatic and best coding practices, and serves as a well-rounded example of how to structure your script and interact with Aurora's Lua API. The code demonstrates proper error handling, making external API requests using the `Http` module, parsing response data using a third party JSON module, persistent storage of user config settings using `IniFile` module, and more.

### ScriptInfo Metadata

Each script must include the following metadata at the beginning of the main script file, defined as global variables.

**Content Scripts:**

```lua
ContentScriptInfo = {
    Title       = "Cool Factor Filter",
    Author      = "Stelio Kontos",
    Description = "Filters games based on their cool factor",
}
```

**Utility Scripts:**

```lua
scriptTitle = "Rick Roll"
scriptAuthor = "Stelio Kontos"
scriptVersion = 1 -- integers only (no decimals)
scriptDescription = "Randomly plays the Stelio Kontos theme song when Aurora starts"
scriptIcon = "icon\\icon.xur" -- valid filetypes are XUR and PNG
scriptPermissions = { "http", "filesystem" } -- if using modules with restricted permissions
```

### Script Permissions

Some modules must be explicitly enabled by including them in the script's `scriptPermissions` metadata in order to be loaded and executed from the calling script at runtime. Modules requiring permissions are:

- Content
- FileSystem
- Http
- Kernel
- Settings
- Sql

Example:

```lua
scriptPermissions = { "filesystem", "http" } -- case-insensitive
```

## Library Documentation

- [Globals](definitions/aurorascriptlib/Globals.lua)
- [Library Modules](definitions/aurorascriptlib)
  - [Script](definitions/aurorascriptlib/library/Script.lua)
  - [Aurora](definitions/aurorascriptlib/library/Aurora.lua)
  - [Content](definitions/aurorascriptlib/library/Content.lua)*
  - [Dvd](definitions/aurorascriptlib/library/Dvd.lua)
  - [FileSystem](definitions/aurorascriptlib/library/FileSystem.lua)*
  - [Http](definitions/aurorascriptlib/library/Http.lua)*
  - [IniFile](definitions/aurorascriptlib/library/IniFile.lua)
  - [Kernel](definitions/aurorascriptlib/library/Kernel.lua)*
  - [Profile](definitions/aurorascriptlib/library/Profile.lua)
  - [Settings](definitions/aurorascriptlib/library/Settings.lua)*
  - [Sql](definitions/aurorascriptlib/library/Sql.lua)*
  - [Thread](definitions/aurorascriptlib/library/Thread.lua)
  - [ZipFile](definitions/aurorascriptlib/library/ZipFile.lua)
  - [GizmoUI](definitions/aurorascriptlib/library/GizmoUI.lua)

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
Script.GetBasePath(): string
Script.FileExists(relativePath: string): boolean
Script.CreateDirectory(relativePath)
Script.IsCanceled(): boolean
Script.IsCancelEnabled(): boolean
Script.SetCancelEnable(enabled: boolean)
Script.RefreshListOnExit(refreshList: boolean)
Script.GetProgress(): unsigned
Script.SetProgress(progress: unsigned, [total: unsigned])
Script.GetStatus(): string
Script.SetStatus(status: string)
Script.ShowNotification(message: string, [notifyType: NotifyType])
Script.ShowMessageBox(title: string, prompt: string, button1text: string, ...): MessageBoxResult
Script.ShowKeyboard(title: string, prompt: string, default: string, flags: KeyboardFlags): KeyboardResult
Script.ShowPasscode(title: string, prompt: string, permissionFlag: unsigned): PasscodeResult
Script.ShowPasscodeEx(title: string, prompt: string): PasscodeExResult
Script.ShowPopupList(title: string, emptyList: string, listContent: table<integer|string, string>): PopupResultDefault
Script.ShowPopupList(title: string, emptyList: string, popupType: PopupType): PopupResult
Script.ShowFilebrowser(basePath: string, selectedItem: string, flags: unsigned): FilebrowserResult
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
-- class methods
Dvd.GetTrayState(): DvdTrayState ---@since 0.7b
Dvd.GetMediaType(): DvdMediaTypes ---@since 0.7b
Dvd.OpenTray(): boolean ---@since 0.7b
Dvd.CloseTray(): boolean ---@since 0.7b
```

##### FileSystem

```lua
-- callback function types
FileSystemProgressRoutine = fun(totalFileSize: number, totalBytesTransferred: number): FileSystemProgressReturnCode
FileSystemSvodProgressRoutine = fun(totalFileSize: number, totalBytesTransferred: number, chunkFileSize: number, chunkBytesTransferred: number, chunkNumber: unsigned, chunkTotal: unsigned, callbackReason: FileSystemCallbackReason): FileSystemProgressReturnCode

-- class methods
FileSystem.InstallTitleFromDisc(virtualTargetPath: string, createContentDirs: boolean, [progressRoutine: FileSystemSvodProgressRoutine]): boolean
FileSystem.CopyDirectory(srcDirPath: string, destDirPath: string, overwrite: boolean, [progressRoutine: FileSystemProgressRoutine]): boolean
FileSystem.MoveDirectory(srcDirPath: string, destDirPath: string, overwrite: boolean, [progressRoutine: FileSystemProgressRoutine]): boolean
FileSystem.CopyFile(srcFilePath: string, destFilePath: string, overwrite: boolean, [progressRoutine: FileSystemProgressRoutine]): boolean
FileSystem.MoveFile(srcFilePath: string, destFilePath: string, overwrite: boolean, [progressRoutine: FileSystemProgressRoutine]): boolean
FileSystem.DeleteDirectory(dirPath: string): boolean
FileSystem.CreateDirectory(dirPath: string): boolean
FileSystem.DeleteFile(filePath: string): boolean
FileSystem.WriteFile(filePath: string, data: string): boolean
FileSystem.ReadFile(filePath: string): string|nil
FileSystem.Rename(curName: string, newName: string): boolean
FileSystem.FileExists(path: string): boolean
FileSystem.GetAttributes(path: string): FileAttributes|unsigned
FileSystem.GetFileSize(filePath: string): unsigned
FileSystem.GetFilesAndDirectories(path: string): FileInfo[]
FileSystem.GetFiles(path: string): FileInfo[]
FileSystem.GetDirectories(path: string): FileInfo[]
FileSystem.GetDrives([contentDrivesOnly: boolean]): DriveInfo[]
FileSystem.GetPartitionSize(driveName: string): number|nil ---@since 0.7b
FileSystem.GetPartitionUsedSpace(driveName: string): number|nil ---@since 0.7b
FileSystem.GetPartitionFreeSpace(driveName: string): number|nil ---@since 0.7b
```

##### Http

```lua
-- callback function types
HttpProgressRoutine = fun(totalFileSize: unsigned, totalBytesTransferred: unsigned, dwReason: HttpCallbackReason): unsigned ---@since 0.7b

-- class methods
Http.Get(url: string, [outputPath: string]): HttpResponse
Http.GetEx(url: string, progressRoutine: HttpProgressRoutine, [outputPath: string]): HttpResponse ---@since 0.7b
Http.Post(url: string, postvars: table, [outputPath: string]): HttpResponse
Http.PostEx(url: string, postvars: table, progressRoutine: HttpProgressRoutine, [outputPath: string]): HttpResponse ---@since 0.7b
Http.UrlEncode(input: string): string
Http.UrlDecode(input: string): string
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
-- class methods
Settings.GetSystem(...: SystemSettingKey): SystemSettingsDictionary|nil
Settings.GetUser(...: UserSettingKey): UserSettingsDictionary|nil
Settings.SetSystem(name: SystemSettingKey, value: string, ...): UpdatedSystemSettingsDictionary|nil
Settings.SetUser(name: UserSettingKey, value: string, ...): UpdatedUserSettingsDictionary|nil
Settings.GetOptions(name: SystemSettingKey|UserSettingKey, settingType: SettingType): OptionsDictionary|nil
Settings.GetSystemOptions(name: SystemSettingKey): OptionsDictionary|nil
Settings.GetUserOptions(name: UserSettingKey): OptionsDictionary|nil
Settings.GetRSSFeeds([enabledOnly: boolean]): RSSFeed[] ---@since 0.7b
Settings.GetRSSFeedById(feedId: unsigned): RSSFeed|nil ---@since 0.7b
Settings.AddRSSFeed(url: string, [enabled: boolean]): unsigned ---@since 0.7b
Settings.DeleteRSSFeed(feedId: unsigned): boolean ---@since 0.7b
Settings.UpdateRSSFeed(feedId: unsigned, url: string, enabled: boolean): boolean ---@since 0.7b
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
