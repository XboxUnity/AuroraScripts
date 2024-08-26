---@meta

---Provides an interface for scanning, retrieving, and managing game content information, such as content metadata, images, and assets.
---
---This module requires the `content` permission to be enabled in the calling script's global `ScriptInfo` table.
---
---### Example
---
---```lua
---ScriptInfo = {
---  -- ...(other fields),
---  Permissions = { "content" }
---}
---```
---@class Content
Content = {}

---@enum ContentItemType
ContentItemType = {
    Unknown     = 0,
    Content     = 1,
    TitleUpdate = 2,
    SavedGame   = 3,
    DLC         = 4,
}

---@enum ContentGroup
ContentGroup = {
	Unknown     = 0,
	Automatic   = 0,
	Default     = 0,

	Xbox360     = 1,
	XBLA        = 2,
	Indie       = 3,
	Xbox1       = 4,
	Unsigned    = 5,
	LibXenon    = 6,

	SystemLink  = 8,
	XLinkKai    = 9,

	Favorite    = 14,
	SavedGame   = 15,
	TitleUpdate = 16,
	DLC         = 17,

	None        = 0xFFFFFFFF,
	Hidden      = 0xFFFFFFFF,
}

---@enum ContentAssetFlags
ContentAssetFlags = {
	Icon       = 0x1,
	Banner     = 0x2,
	BoxArt     = 0x4,
	Slot       = 0x8,
	Background = 0x10,
	Screenshot = 0x20,
	TrailerASX = 0x2000000,
	Trailer    = 0x4000000,
	Info       = 0x8000000,
}

---@enum ContentFlags
ContentFlags = {
	KinectCompatible     = 0x1,
	SystemLinkCompatible = 0x2,
	RetailSigned         = 0x4,
	DevKitSigned         = 0x8,
	PendingExtraction    = 0x10,
	DiscGame             = 0x20,
}

---@enum ContentItemCaseIndex
ContentItemCaseIndex = {
    Default = 0,
    Xbox    = 0,
    Kinect  = 1,
    Arcade  = 2,
    Indie   = 3,
    Disc    = 4,
}

---@enum ContentGenreFlags
ContentGenreFlags = {
    Other              = 0x0001,
    ActionAdventure    = 0x0002,
    Family             = 0x0004,
    Fighting           = 0x0008,
    Music              = 0x0010,
    Platformer         = 0x0020,
    RacingFlying       = 0x0040,
    RolePlaying        = 0x0080,
    Shooter            = 0x0100,
    StrategySimulation = 0x0200,
    SportsRecreation   = 0x0400,
    BoardCard          = 0x0800,
    Classics           = 0x1000,
    PuzzleTrivia       = 0x2000,
}

---Represents a bitmask of capabilities flags for a content item, structured like a ULARGE_INTEGER.
---@class Capabilities
---@field HighPart unsigned
---@field LowPart unsigned

---Represents a combined date and time structure, derived both FILETIME and SYSTEMTIME structures.
---@class CombinedDateTime
---@field HighPart unsigned     --- High part of the FILETIME structure.
---@field LowPart unsigned      --- Low part of the FILETIME structure.
---@field Month unsigned        --- Month (1-12).
---@field Day unsigned          --- Day of the month (1-31).
---@field Year unsigned         --- Year.
---@field DayOfWeek unsigned    --- Day of the week (1-7, Sunday = 1).
---@field Hour unsigned         --- Hour (0-23).
---@field Minute unsigned       --- Minute (0-59).
---@field Second unsigned       --- Second (0-59).
---@field Milliseconds unsigned --- Milliseconds (0-999).

---Represents a content item, such as a game title, with associated metadata and properties.
---@class ContentItem
---@field Id unsigned                      --- The content ID.
---@field TitleId unsigned                 --- The title ID.
---@field MediaId unsigned                 --- The media ID.
---@field BaseVersion unsigned             --- The base version.
---@field Name string                      --- The title name.
---@field Type ContentItemType 		       --- The type of content (e.g., game, TU, game save, DLC).
---@field CaseIndex ContentItemCaseIndex   --- The case index based on the content flags (e.g., Xbox, Kinect, Arcade, Indie, Disc).
---@field Description string               --- The title description.
---@field ReleaseDate string               --- The release date in string format.
---@field Developer string                 --- The developer name.
---@field Publisher string                 --- The publisher name.
---@field DiscNum unsigned                 --- The disc number for multi-disc sets.
---@field DiscsInSet unsigned              --- The total number of discs in the set.
---@field Root string                      --- The root directory name.
---@field VirtualRoot string               --- The virtual root directory name.
---@field Directory string                 --- The content directory name.
---@field Executable string                --- The executable filename.
---@field Flags ContentFlags               --- The content flags (e.g., Kinect compatible, system link compatible, retail signed, dev kit signed).
---@field AssetFlag ContentAssetFlags      --- The content asset flags (e.g., icon, banner, box art, background, screenshot).
---@field Genre ContentGenreFlags          --- The genre flags.
---@field GenreStr string                  --- The genre description based on the genre flags.
---@field Enabled boolean                  --- A flag indicating if the content is enabled.
---@field Hidden boolean                   --- A flag indicating if the content is hidden.
---@field SystemLink boolean               --- A flag indicating if SystemLink is enabled.
---@field Favorite boolean                 --- A flag indicating if the content is marked as favorite.
---@field LiveRating number                --- The online rating.
---@field LiveRaters unsigned              --- The number of raters for the online rating.
---@field Group ContentGroup               --- The content group identifier (e.g., Xbox 360, XBLA, Indie, Xbox 1, Unsigned, LibXenon).
---@field DefaultGroup ContentGroup        --- The default content group identifier (e.g., Xbox 360, XBLA, Indie, Xbox 1, Unsigned, LibXenon).
---@field ScriptData string                --- The script variable associated with the scan path data.
---@field DateAdded CombinedDateTime       --- The date and time the content was added.
---@field LastPlayed CombinedDateTime      --- The date and time the content was last played.
---@field CapabilitiesFlag unsigned        --- The general capabilities flags (LowPart only). -- TODO: Should be Capabilities type (ULONGLONG), but the Aurora Lua VM source will need updated with the current `DWORD` cast removed.
---@field CapabilitiesOnline unsigned      --- The online capabilities flags (LowPart only). -- TODO: Should be Capabilities type (ULONGLONG), but the Aurora Lua VM source will need updated with the current `DWORD` cast removed.
---@field CapabilitiesOffline Capabilities --- The offline capabilities flags.

---NOTE: This probably should be an overload, since titleid is always used if searchtext is provided (even though that makes no sense to me)
---
---Finds content items by title ID, optionally filtering by title name using regex pattern matching.
---@param titleId? unsigned Optional. The title ID to search for, or nil to return all content items.
---@param regexPattern? string Optional. A regular expression pattern to match titles by name.
---@return ContentItem[] # An array of matching content items.
---@since 0.6b
function Content.FindContent(titleId, regexPattern) end

---Retrieves information about a content item.
---@param contentId unsigned The content ID of the title to retrieve information for.
---@return ContentItem|nil # A table containing content title information, or nil if the content item is not found.
---@since 0.6b
function Content.GetInfo(contentId) end

---NOTE: Ambiguous: `SetTitleName` or `SetTitle` would be more suitable. Refer to naming used in src: "Aurora\Aurora\Tools\Content\ContentManager.h", "Aurora\Aurora\Tools\Content\ContentItem.cpp"
---
---Sets the name for a content item with the specified content ID.
---@param contentId unsigned The content ID of the title to update.
---@param name string The new name for the content item.
---@return boolean # True if the name was set successfully, false otherwise.
---@since 0.6b
function Content.SetTitle(contentId, name) end

---Sets the description for a content item with the specified ID.
---@param contentId unsigned The content ID of the title to update.
---@param description string The new description for the content item.
---@return boolean # True if the description was set successfully, false otherwise.
---@since 0.6b
function Content.SetDescription(contentId, description) end

---Sets the developer name for a content item with the specified ID.
---@param contentId unsigned The content ID of the title to update.
---@param developer string The new developer name for the content item.
---@return boolean # True if the developer name was set successfully, false otherwise.
---@since 0.6b
function Content.SetDeveloper(contentId, developer) end

---Sets the publisher name for a content item with the specified ID.
---@param contentId unsigned The content ID of the title to update.
---@param publisher string The new publisher name for the content item.
---@return boolean # True if the publisher name was set successfully, false otherwise.
---@since 0.6b
function Content.SetPublisher(contentId, publisher) end

---Sets the release date for a content item with the specified ID.
---@param contentId unsigned The content ID of the title to update.
---@param releaseDate string The new release date for the content item in `YYYY-MM-DD` format.
---@return boolean # True if the release date was set successfully, false otherwise.
---@since 0.6b
function Content.SetReleaseDate(contentId, releaseDate) end

---Represents the types of content assets that can be set for a content item.
---@enum ContentAssetType
ContentAssetType = {
	Icon       = 1,
	Banner     = 2,
	BoxArt     = 3,
	Background = 4,
	Screenshot = 5,
}

---Sets an asset for a content item with the specified ID (e.g., icon, banner, box art, backgrounds).
---@param contentId unsigned The content ID of the title to update.
---@param imagePath string The filepath of the new asset image, relative to the script base path. Supported file types are PNG, JPEG, BMP, and DDS.
---@param assetType ContentAssetType The type of asset to set.
---@param screenshotIndex? unsigned Optional. For screenshots, the index of the screenshot to set (0-20). Defaults to 0.
---@return boolean # True if the asset was set successfully, false otherwise.
---@since 0.6b
function Content.SetAsset(contentId, imagePath, assetType, screenshotIndex) end

---Starts a scan for new game titles in the configured scan paths.
---@return boolean # True if the scan started successfully, false otherwise.
---@since 0.6b
function Content.StartScan() end

---Checks if a content scan is currently in progress.
---@return boolean # True if a scan is in progress, false otherwise.
---@since 0.6b
function Content.IsScanning() end

return Content
