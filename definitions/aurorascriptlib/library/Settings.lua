---@meta

---Provides an interface for accessing and modifying system and user settings, as well as managing RSS feeds.
---@class Settings
Settings = {}

---Represents the Settings Types.
---@enum SettingType
SettingType = {
    Unknown       = 0,
    System        = 1,
    User          = 2,
}

---Represents the System Settings used in Aurora.
---@alias SystemSettingKey
---| '"SMBServerEnabled"'
---| '"SMBHostname"'
---| '"SMBWorkgroup"'
---| '"SMBUsername"'
---| '"SMBPassword"'
---
---| '"HTTPServerEnabled"'
---| '"HTTPPort"'
---| '"HTTPSecurity"'
---| '"HTTPUsername"'
---| '"HttpPassword"'
---
---| '"NetISOEnabled"'
---| '"NetISOSearchEnabled"'
---| '"NetISOSearchInterval"'
---| '"NetISOServerIp"'
---| '"NetISOServerPort"'
---
---| '"FTPServerEnabled"'
---| '"FTPPort"'
---| '"FTPUsername"'
---| '"FTPPassword"'
---
---| '"CXLoadAtBoot"'
---| '"CXNotification"'
---
---| '"UnityConnection"'
---| '"UnityUsername"'
---| '"UnityApiKey"'
---
---| '"MarketplaceLocale"'
---| '"MarketplaceDownloadIcon"'
---| '"MarketplaceDownloadBoxart"'
---| '"MarketplaceDownloadBanner"'
---| '"MarketplaceDownloadBackground"'
---| '"MarketplaceDownloadVideo"'
---| '"MarketplaceDownloadScreenshot"'
---| '"MarketplaceMaxDownloadsScreenshots"'
---
---| '"ScanIncludeDLC"'
---| '"ScanIncludeQuickboot"'
---| '"ScanAutoStart"'
---| '"ScanRemoveFullGameFromXBLATitle"'
---| '"ScanRemoveFullGameFromXNATitle"'
---
---| '"PluginLoadAtBoot"'
---| '"PluginLiNK"'
---| '"PluginUPNP"'
---| '"PluginPortBroadcast"'
---| '"PluginPortData"'
---| '"PluginHUDRSS"'
---| '"PluginWebUI"'
---| '"PluginPortWebUI"'
---| '"PluginScreenCapture"'
---| '"PluginScreenCaptureActivator"'
---| '"PluginScreenCaptureTrigger"'
---
---| '"ProfileSignInOption"'
---| '"ProfileAutoSignInXUID"'
---
---| '"Skin"'
---| '"SkinAnimation"'
---| '"DefaultQuickView"'
---
---| '"OverscanHorizontal"'
---| '"OverscanVertical"'
---
---| '"RunXexOnce"'
---| '"NotifyUpdateAvailable"'
---| '"LanguagePack"'
---
---| '"RunLuaAtBoot"'
---| '"UseCelsius"'
---| '"NTPAtBoot"'
---| '"NTPNumRetries"'
---| '"NTPRetryInterval"'
---| '"EnableLetterbox"'
---| '"TUScanAutoStart"'
---| '"TUScanAtBoot"'
---| '"IdleStatus"'
---| '"AlternateSplash"'
---| '"XHTTPAutoEnable"'
---| '"ProfileDiscPanelEnabled"'
---| '"AvatarProfilePicture"'
---
---| '"RSSFeedEnabled"'
---| '"RSSFeedSpeed"'
---| '"RSSFeedMaxItems"'
---
---| '"DLOverrideEnabled"'
---| '"DLContPatchEnabled"'
---| '"DLXBLAPatchEnabled"'
---| '"DLLicensePatchEnabled"'
---| '"DLNoHealthEnabled"'
---| '"DLAutoSwapEnabled"'
---| '"DLPingLimitEnabled"'
---| '"DLXHttpPatchEnabled"'
---| '"DLNoNetStoreEnabled"'
---| '"DLDevLinkEnabled"'
---| '"DLFakeLiveEnabled"'
---
---| '"TitleUpdateDevice"'
---| '"PCPasscode"'
---| '"PCPermissions"'

---Represents the User Settings used in Aurora.
---@alias UserSettingKey
---| '"FunctionSort"'
---| '"FunctionSubtitle"'
---| '"FunctionFilters"'
---| '"LayoutGUID"'
---
---| '"ViewSortDescending"'
---| '"ViewFavoritesOnly"'
---| '"ViewShowHidden"'
---
---| '"BackgroundAnimateOverride"'
---| '"BackgroundAnimate"'
---| '"BackgroundColorFactor"'
---| '"BackgroundTimeScale"'
---| '"BackgroundEffectValue"'
---| '"BackgroundFile"'

---Represents the Settings categories.
---@alias SettingCategory
---| '"unknown"'
---| '"general"'
---| '"content"'
---| '"security"'
---| '"plugin"'
---| '"profile"'
---| '"theme"'
---| '"error"'

---Represents the Settings variable types.
---@alias SettingVarType
---| '"unknown"'
---| '"bool"'
---| '"dword"'
---| '"ulonglong"'
---| '"integer"'
---| '"long"'
---| '"string"'
---| '"float"'
---| '"array"'
---| '"struct"'
---| '"class"'
---| '"hash"'
---| '"option.single"'
---| '"option.multi"'
---| '"tree.single"'
---| '"tree.multi"'
---| '"range"'

---Represents a system setting with its properties and metadata.
---@class SystemSetting
---@field name SystemSettingKey The name of the system setting, represented by a `SystemSettingKey`.
---@field value string The current value of the system setting.
---@field default string The default value of the system setting.
---@field regex string A regular expression that the value must match.
---@field vartype SettingVarType The type of the variable as a string alias `SettingVarType`.
---@field category SettingCategory The category of the setting as a string alias `SettingCategory`.
---@field readonly boolean Whether the setting is read-only.

---Represents a user setting with its properties and metadata.
---@class UserSetting
---@field name UserSettingKey The name of the user setting, represented by a `UserSettingKey`.
---@field value string The current value of the user setting.
---@field default string The default value of the user setting.
---@field regex string A regular expression that the value must match.
---@field vartype SettingVarType The type of the variable as a string alias `SettingVarType`.
---@field category SettingCategory The category of the setting as a string alias `SettingCategory`.
---@field xuid string The XUID associated with the setting.
---@field readonly boolean Whether the setting is read-only.

---@alias SystemSettingsDictionary table<SystemSettingKey, SystemSetting> A dictionary containing system settings keyed by setting name.
---@alias UserSettingsDictionary table<UserSettingKey, UserSetting> A dictionary containing user settings keyed by setting name.

---Gets one or more system settings.
---@param ... SystemSettingKey Optional. The names of the settings to retrieve.
---@return SystemSettingsDictionary|nil # A dictionary where each key is a setting name and the value is a `SystemSetting` table, or `nil` if no settings were found.
---@since 0.6b
function Settings.GetSystem(...) end

---Gets one or more user settings.
---@param ... UserSettingKey Optional. The names of the settings to retrieve.
---@return UserSettingsDictionary|nil # A dictionary where each key is a setting name and the value is a `UserSetting` table, or `nil` if no settings were found.
---@since 0.6b
function Settings.GetUser(...) end

---Represents a system setting with its updated status.
---@class UpdatedSystemSetting : SystemSetting
---@field success boolean Indicates whether the setting was updated successfully.

---Represents a user setting with its updated status.
---@class UpdatedUserSetting : UserSetting
---@field success boolean Indicates whether the setting was updated successfully.

---@alias UpdatedSystemSettingsDictionary table<SystemSettingKey, UpdatedSystemSetting> A dictionary containing updated system settings keyed by setting name, with an added `success` field indicating whether the setting was updated successfully.
---@alias UpdatedUserSettingsDictionary table<UserSettingKey, UpdatedUserSetting> A dictionary containing updated user settings keyed by setting name, with an added `success` field indicating whether the setting was updated successfully.

---Sets one or more system settings.
---@param name SystemSettingKey The name of the setting to modify.
---@param value string The new value for the setting.
---@param ... string] Optional. Additional setting name and value pairs. Each pair consists of a `SystemSettingKey` and its corresponding value.
---@return UpdatedSystemSettingsDictionary|nil # A dictionary where each key is a setting name and the value is an `UpdatedSystemSetting` table, or `nil` if no settings were found found.
---@since 0.6b
function Settings.SetSystem(name, value, ...) end

---Sets one or more user settings.
---@param name UserSettingKey The name of the setting to modify.
---@param value string The new value for the setting.
---@param ... string] Optional. Additional setting name and value pairs. Each pair consists of a `UserSettingKey` and its corresponding value.
---@return UpdatedUserSettingsDictionary|nil # A dictionary where each key is a setting name and the value is an `UpdatedUserSetting` table, or `nil` if no settings were found found.
---@since 0.6b
function Settings.SetUser(name, value, ...) end

---@alias OptionsDictionary table<string, string> A dictionary containing setting options keyed by option name.

---TODO: Verify returns for Option getter methods
---
---Gets the available options for a setting based on its type.
---@param name SystemSettingKey|UserSettingKey The name of the setting.
---@param settingType SettingType The type of the setting.
---@return OptionsDictionary|nil # A dictionary where each key is an option name and the value is ???, or `nil` if no options are available.
---@since 0.6b
function Settings.GetOptions(name, settingType) end

---TODO: Verify returns for Option getter methods
---
---Gets the available options for a system setting.
---@param name SystemSettingKey The name of the system setting.
---@return OptionsDictionary|nil # A dictionary where each key is an option name and the value is ???, or `nil` if no options are available.
---@since 0.6b
function Settings.GetSystemOptions(name) end

---TODO: Verify returns for Option getter methods
---
---Gets the available options for a user setting.
---@param name UserSettingKey The name of the user setting.
---@return OptionsDictionary|nil # A dictionary where each key is an option name and the value is ???, or `nil` if no options are available.
---@since 0.6b
function Settings.GetUserOptions(name) end

---Represents an RSS feed.
---@class RSSFeed
---@field Id unsigned The unique identifier of the RSS feed.
---@field Url string The URL of the RSS feed.
---@field Enabled boolean Whether the RSS feed is enabled.

---Gets the list of RSS feeds.
---@param enabledOnly? boolean Optional. If `true`, only enabled RSS feeds are returned. Defaults to `false`.
---@return RSSFeed[] # An array of RSS feeds.
---@since 0.7b
function Settings.GetRSSFeeds(enabledOnly) end

---Gets an RSS feed by its unique identifier.
---@param feedId unsigned The unique identifier of the RSS feed.
---@return RSSFeed|nil # The RSS feed if found, or `nil` if not found.
---@since 0.7b
function Settings.GetRSSFeedById(feedId) end

---Adds a new RSS feed.
---@param url string The URL of the RSS feed.
---@param enabled? boolean Optional. Whether the RSS feed should be enabled. Defaults to `true`.
---@return unsigned # The unique identifier of the added RSS feed.
---@since 0.7b
function Settings.AddRSSFeed(url, enabled) end

---Deletes an RSS feed by its unique identifier.
---@param feedId unsigned The unique identifier of the RSS feed.
---@return boolean # `true` if the feed was deleted successfully, `false` otherwise.
---@since 0.7b
function Settings.DeleteRSSFeed(feedId) end

---Updates an existing RSS feed.
---@param feedId unsigned The unique identifier of the RSS feed.
---@param url string The new URL of the RSS feed.
---@param enabled boolean Whether the RSS feed should be enabled.
---@return boolean # `true` if the feed was updated successfully, `false` otherwise.
---@since 0.7b
function Settings.UpdateRSSFeed(feedId, url, enabled) end

return Settings
