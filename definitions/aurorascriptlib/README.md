# Aurora Scripting Library - Module Definitions

Aurora's scripting library API exposes several [global objects and functions](library/Globals.lua), and includes numerous feature-rich modules designed to extend the functionality of custom scripts by interfacing with Aurora's UI, filesystem, and system internals.

## Library Usage

The included modules are available for use in all Content and Utility Scripts, and are preloaded into the Lua execution environment at runtime, eliminating the need to `require` them in your script.

[LuaCATS](https://luals.github.io/wiki/annotations/) annotations for each module serve as a manual documentation reference, and provide intellisense support and type hinting when used in conjunction with the [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) VS Code extension by sumneko.

*Note that these annotations are a work in progress; contributions through pull requests are welcome.*

## API Reference

- [Globals](#globals)
- [Library Modules](#library-modules)
  - [Script](#script-module)
  - [Aurora](#aurora-module)
  - [Dvd](#dvd-module)
  - [IniFile](#inifile-module)
  - [Kernel](#kernel-module)*
  - [Profile](#profile-module)
  - [Settings](#settings-module)*
  - [Sql](#sql-module)*
  - [Thread](#thread-module)
  - [ZipFile](#zipfile-module)

*Requires script permissions.

### Globals

Global functions and objects that are available to all scripts. Global objects are used primarily by Content Scripts (Filters, Sorts, Subtitles). See [Globals.lua](library/Globals.lua) for detailed documentation and annotations.

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

### Library Modules

#### Script module

Provides an interface for interacting with the script environment, including file I/O, XUI controls, and script states. See [Script.lua](library/Script.lua) for detailed documentation and annotations

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

#### Aurora module

Provides an interface for common tasks such as retrieving Aurora version info, hashing, querying HAL/system status, performing basic SMC operations, and more. See [Aurora.lua](library/Aurora.lua) for detailed documentation and annotations

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

#### Dvd module

Provides an interface for interacting with the DVD drive on the console. See [Dvd.lua](library/Dvd.lua) for detailed documentation and annotations

```lua
-- class methods
Dvd.GetTrayState(): DvdTrayState ---@since 0.7b
Dvd.GetMediaType(): DvdMediaTypes ---@since 0.7b
Dvd.OpenTray(): boolean ---@since 0.7b
Dvd.CloseTray(): boolean ---@since 0.7b
```

#### IniFile module

Provides an interface for reading and writing INI files. See [IniFile.lua](library/IniFile.lua) for detailed documentation and annotations

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

#### Kernel module

Provides an interface for interacting with system-level kernel operations such as querying system information, managing hardware settings, and controlling console behavior. See [Kernel.lua](library/Kernel.lua) for detailed documentation and annotations

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

#### Profile module

Provides an interface for interacting with user profiles, such as retrieving XUIDs, GamerTags, achievements, and more. See [Profile.lua](library/Profile.lua) for detailed documentation and annotations

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

#### Settings module

Provides an interface for accessing and modifying system and user settings, as well as managing RSS feeds. See [Settings.lua](library/Settings.lua) for detailed documentation and annotations

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

#### Sql module

Provides an interface for interacting with an SQLite database instance. See [Sql.lua](library/Sql.lua) for detailed documentation and annotations

```lua
-- class methods
Sql.Execute(query: string): boolean
Sql.ExecuteFetchRows(query: string): SqlResultSet|nil
```

#### Thread module

It's just a single method. That's it. See [Thread.lua](library/Thread.lua) for detailed documentation and annotations

```lua
-- class methods
Thread.Sleep(milliseconds: unsigned)
```

#### ZipFile module

Provides an interface for opening and extracting the contents of a ZIP archive using 7-Zip. See [ZipFile.lua](library/ZipFile.lua) for detailed documentation and annotations

```lua
-- class methods
ZipFile.OpenFile(filePath: string, [createIfNotExist: boolean]): userdata|nil

-- userdata methods
userdata:Extract(destDir: string): boolean
```

