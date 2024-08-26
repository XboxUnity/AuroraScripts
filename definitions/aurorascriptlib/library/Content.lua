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

---@alias Capabilities { HighPart: unsigned, LowPart: unsigned }

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

---Represents a content item, such as a game title, with associated metadata and assets.
---@class ContentItem
---@field Id unsigned
---@field Name string
---@field TitleId unsigned
---@field Type unsigned
---@field LastPlayed CombinedDateTime
---@field DateAdded CombinedDateTime
---@field Root string
---@field VirtualRoot string
---@field Directory string
---@field Executable string
---@field Enabled boolean
---@field AssetFlag unsigned
---@field MediaId unsigned
---@field BaseVersion unsigned
---@field DiscNum unsigned
---@field DiscsInSet unsigned
---@field Developer string
---@field Publisher string
---@field Description string
---@field ReleaseDate string
---@field Flags unsigned
---@field Genre unsigned
---@field GenreStr string
---@field LiveRating unsigned
---@field LiveRaters unsigned
---@field SystemLink boolean
---@field Hidden boolean
---@field Favorite boolean
---@field Group unsigned
---@field ScriptData string
---@field DefaultGroup unsigned
---@field CaseIndex unsigned
---@field CapabilitiesFlag unsigned
---@field CapabilitiesOnline unsigned
---@field CapabilitiesOffline Capabilities

---NOTE: This probably should be an overload, since titleid is always used if searchtext is provided (even though that makes no sense to me)
---
---Finds content items by title ID, optionally filtering by title name using regex pattern matching.
---@param titleId? unsigned Optional. The title ID to search for, or nil to return all content items.
---@param searchText? string Optional. A regular expression pattern to match titles by name.
---@return ContentItem[] # An array of matching content items.
---@since 0.6b
function Content.FindContent(titleId, searchText) end

---Retrieves information about a content item.
---@param contentId unsigned The content ID of the title to retrieve information for.
---@return ContentItem|nil # A table containing content title information, or nil if the content item is not found.
---@since 0.6b
function Content.GetInfo(contentId) end

---NOTE: Ambiguous: `SetName` would be more suitable.
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
	Icon       = 1, -- Icon asset type.
	Banner     = 2, -- Banner asset type.
	Boxart     = 3, -- Box art (cover) asset type.
	Background = 4, -- Background asset type.
	Screenshot = 5, -- Screenshot asset type.
}

---Sets an asset for a content item with the specified ID (e.g., icon, banner, box art, backgrounds).
---@param contentId unsigned The content ID of the title to update.
---@param imagePath string The new asset image filepath for the content item, relative to the script base path. Supported filetypes are PNG, JPEG, BMP, and DDS.
---@param assetType ContentAssetType The type of asset to set.
---@param screenshotIndex? unsigned Optional. The index of the screenshot to set (0-20). Only used for `ContentAssetType.Screenshot` assets. Defaults to 0.
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
