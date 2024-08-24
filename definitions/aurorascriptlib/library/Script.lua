---@meta

---Provides an interface for interacting with the script environment, including file I/O, XUI controls, and script states.
---@class Script
Script = {}

---Gets the base path of the script.
---@return string # The base path of the script.
---@since 0.6b
function Script.GetBasePath() end

---Checks if a file exists at the specified relative path.
---@param relativePath string file path to check, relative to the script base path.
---@return boolean # True if the file exists, false otherwise.
---@since 0.6b
function Script.FileExists(relativePath) end

---Creates a directory at the specified path, including any necessary parent directories in that path.
---@param relativePath string The directory path to create, relative to the script base path.
---@since 0.6b
function Script.CreateDirectory(relativePath) end

---Checks if the script execution has been canceled.
---@return boolean # True if the script has been canceled, false otherwise.
---@since 0.6b
function Script.IsCanceled() end

-- NOTE: Inconsistent naming: `IsCancelEnabled` -> `GetCancelEnabled`/`GetCancelationEnabled`
---Gets whether script cancelation is enabled.
---@return boolean # True if the script can be canceled, false otherwise.
---@since 0.6b
function Script.IsCancelEnabled() end

-- NOTE: Inconsistent naming: `SetCancelEnable` -> `SetCancelEnabled`/`SetCancelationEnabled`
---Enables or disables the ability to cancel the script.
---@param enabled boolean True to enable script cancelation, false to disable.
---@since 0.6b
function Script.SetCancelEnable(enabled) end

-- NOTE: Intended name was `SetRefreshListOnExit` (based on original function list and c++ source comments), but Lua VM expects `RefreshListOnExit`
---Sets whether the scripts list should be refreshed when the script exits.
---@param refreshList boolean True to refresh the content list on exit, false otherwise.
---@since 0.6b
function Script.RefreshListOnExit(refreshList) end

---Gets the current progress value of the script execution.
---@return unsigned # The current progress value.
---@since 0.6b
function Script.GetProgress() end

---Sets the progress value for the script execution.
---@param progress unsigned The new progress value.
---@param total? unsigned Optional. The total value for calculating progress percentage. Defaults to 100.
---@since 0.6b
function Script.SetProgress(progress, total) end

---Gets the current status message of the script execution.
---@return string # The current status message.
---@since 0.6b
function Script.GetStatus() end

---Sets the status message for the script execution.
---@param status string The new status message.
---@since 0.6b
function Script.SetStatus(status) end

-- TODO: Include max streng lengths for notifications, messagebox titles/prompts/button strings, etc. in annotations

-- NOTE: NotifyType also used in GizmoUI.lua
---@enum NotifyType
NotifyType = {
    Info    = 0,
    System  = 1,
    Warning = 2,
    Error   = 3,
    Xam     = 4, -- Forces the system to use Xam's popup
}

---Displays a notification with the specified message.
---@param message string The message to display.
---@param notifyType? NotifyType Optional. The type of notification. Defaults to `NotifyType.Info`.
---@since 0.6b
function Script.ShowNotification(message, notifyType) end

---@alias MessageBoxResult { Canceled: boolean, Button: unsigned? }

---Displays a message box UI with one or more selection buttons.
---@param title string The title of the message box dialog.
---@param prompt string The prompt message to display.
---@param button1text string The text for the first button.
---@param ... string Additional button strings. Max buttons total is 2.
---@return MessageBoxResult # A table containing whether the operation was canceled, and the index of the selected button if not canceled.
---@since 0.6b
function Script.ShowMessageBox(title, prompt, button1text, ...) end

---@alias KeyboardResult { Canceled: boolean, Buffer: string? }

---Displays a keyboard input UI.
---@param title string The title of the keyboard dialog.
---@param prompt string The prompt message to display.
---@param default string The default text to display in the input field.
---@param flags KeyboardFlags Additional flags for setting the keyboard behavior.
---@return KeyboardResult # A table containing whether the operation was canceled, and the input buffer if not canceled.
---@since 0.6b
function Script.ShowKeyboard(title, prompt, default, flags) end

---@alias PasscodeResult { Canceled: boolean, Authorized: boolean? }

---Displays a passcode input UI.
---@param title string The title of the passcode dialog.
---@param prompt string The prompt message to display.
---@param permissionFlag unsigned The permission flag required for the passcode.
---@return PasscodeResult # A table containing whether the operation was canceled, and whether the passcode was authorized if not canceled.
---@since 0.6b
function Script.ShowPasscode(title, prompt, permissionFlag) end

---@alias PasscodeExResult { Canceled: boolean, Passcode: unsigned? }

---Displays an extended passcode input UI.
---@param title string The title of the passcode dialog.
---@param prompt string The prompt message to display.
---@return PasscodeExResult # A table containing whether the operation was canceled, and the entered passcode if not canceled.
---@since 0.6b
function Script.ShowPasscodeEx(title, prompt) end

---@enum PopupType
PopupType = {
    Default       = 0, -- Standard popup type with user-provided content
    Background    = 1, -- Background selection popup
    Skin          = 2, -- Skin selection popup
    CoverLayout   = 3, -- Cover layout selection popup
    Language      = 4, -- Language selection popup
    ProfileSelect = 5, -- Profile selection popup
    DeviceSelect  = 6, -- Device selection popup
}

---Represents the table structure returned by a default popup list selection.
---@class PopupReturnValueDefault
---@field Key number|string The key of the selected item.
---@field Value string The value of the selected item.

---Represents the result of a default popup list selection.
---@class PopupResultDefault
---@field Canceled boolean
---@field Selected PopupReturnValueDefault|nil

---Displays a default popup list selection UI with user-provided content.
---@param title string The title of the popup list dialog.
---@param emptyList string The message to display if the list is empty.
---@param listContent table<integer|string, string> An array or dictionary to populate the list.
---@return PopupResultDefault # A table containing whether the operation was canceled, and the selected item data as a `PopupReturnValueDefault` table if not canceled.
---@since 0.6b
function Script.ShowPopupList(title, emptyList, listContent) end

---Represents the table structure returned by a `PopupType.Background` popup list selection.
---@class PopupReturnValueBackground
---@field BuiltIn boolean
---@field FileSize unsigned
---@field FileName string
---@field FilePath string
---@field FileMd5 string

---Represents the table structure returned by a `PopupType.Skin` popup list selection.
---@class PopupReturnValueSkin
---@field Compressed boolean
---@field FileSize unsigned
---@field FileName string
---@field FilePath string
---@field DisplayName string
---@field Author string
---@field Description string
---@field CreationDate string
---@field Revision string

---Represents the table structure returned by a `PopupType.CoverLayout` popup list selection.
---@class PopupReturnValueCoverLayout
---@field LayoutIndex unsigned
---@field Name string
---@field FilePath string
---@field DisplayName string
---@field Author string
---@field LayoutGUID string

---Represents the table structure returned by a `PopupType.Language` popup list selection.
---@class PopupReturnValueLanguage
---@field FileName string
---@field FilePath string
---@field DisplayName string
---@field Translator string
---@field Language string
---@field LanguageCode string

---Represents the table structure returned by a `PopupType.ProfileSelect` popup list selection.
---@class PopupReturnValueProfileSelect
---@field SignedIn boolean
---@field GamerTag string
---@field VirtualRoot string
---@field ProfileId string
---@field ImageLocator string

---Represents the table structure returned by a `PopupType.DeviceSelect` popup list selection.
---@class PopupReturnValueDeviceSelect
---@field DeviceName string
---@field DeviceId string
---@field VirtualRoot string
---@field MountPoint string
---@field PermissionFlag unsigned
---@field DeviceType unsigned
---@field FreeSpace unsigned
---@field TotalSpace unsigned

---Represents the result of a `PopupType` popup list selection.
---@class PopupResult
---@field Canceled boolean
---@field Selected PopupReturnValueBackground|PopupReturnValueSkin|PopupReturnValueCoverLayout|PopupReturnValueLanguage|PopupReturnValueProfileSelect|PopupReturnValueDeviceSelect|nil

---@alias PopupResultBackground { Canceled: boolean, Selected: PopupReturnValueBackground? } Represents a specific `PopupResult` for a `PopupType.Background` popup list selection.
---@alias PopupResultSkin { Canceled: boolean, Selected: PopupReturnValueSkin? } Represents a specific `PopupResult` for a `PopupType.Skin` popup list selection.
---@alias PopupResultCoverLayout { Canceled: boolean, Selected: PopupReturnValueCoverLayout? } Represents a specific `PopupResult` for a `PopupType.CoverLayout` popup list selection.
---@alias PopupResultLanguage { Canceled: boolean, Selected: PopupReturnValueLanguage? } Represents a specific `PopupResult` for a `PopupType.Language` popup list selection.
---@alias PopupResultProfileSelect { Canceled: boolean, Selected: PopupReturnValueProfileSelect? } Represents a specific `PopupResult` for a `PopupType.ProfileSelect` popup list selection.
---@alias PopupResultDeviceSelect { Canceled: boolean, Selected: PopupReturnValueDeviceSelect? } Represents a specific `PopupResult` for a `PopupType.DeviceSelect` popup list selection.

---Displays a popup list selection UI of the specified popup type.
---
---Narrow the intellisense type checking and hinting features to fields for the specified `PopupType` by marking the return value with a
---[`@type`](https://luals.github.io/wiki/annotations/#type) or [`@cast`](https://luals.github.io/wiki/annotations/#cast) annotation:
--- 1. `---@type PopupResultXXX` (on same line or line above the result variable declaration)
--- 2. `---@cast resultVar PopupResultXXX` (on same line or anywhere following the result variable declaration)
---
---### Example:
---```lua
------@type PopupResultProfileSelect
---local popupResult = Script.ShowPopupList("Choose a profile", "No profiles", PopupType.ProfileSelect)
---if not popupResult.Canceled and popupResult.Selected then
---    print(popupResult.Selected.GamerTag .. " is " .. (popupResult.Selected.SignedIn and "signed in" or "not signed in"))
---end
---```
---@param title string The title of the popup list dialog.
---@param emptyList string The message to display if the list is empty.
---@param popupType PopupType The type of popup to display.
---@return PopupResult # A table containing whether the operation was canceled, and the selected item data as a `PopupReturnValueXXX` table if not canceled.
---@since 0.6b
function Script.ShowPopupList(title, emptyList, popupType) end

---Represents the type of the file object. Can be a bitwise combination of the following flags.
---@enum FileTypeFlags
FileTypeFlags = {
    UNKNOWN    = 0x0,
    ROOTNODE   = 0x1,
    NODE       = 0x2,
    DEVICE     = 0x4,
    DIRECTORY  = 0x8,
    FILE       = 0x10,
    CUSTOM     = 0x20,
    LAUNCHABLE = 0x40,

    VIRTUAL    = 0x100,
    SYSTEM     = 0x200,
    CONTENT    = 0x400,
    CONNX      = 0x800,
    SMB        = 0x1000,

    LOCAL      = 0x10000,
    NETWORK    = 0x20000,
}

---@enum FileExecType
FileExecType = {
    None    = 0, -- No execution type.
    XEX     = 1, -- XEX executable.
    XBE     = 2, -- XBE executable.
    XEXCON  = 3, -- XEX container executable.
    XBECON  = 4, -- XBE container executable.
    XNACON  = 5, -- XNA container executable.
    ELF     = 6, -- ELF executable.
}

---Represents a file object with information about the file.
---@class FileObject
---@field VirtualRoot string The virtual root of the file.
---@field SystemRoot string The system root of the file.
---@field MountPoint string The mount point of the file.
---@field RelativePath string The relative path of the file.
---@field Name string The name of the file.
---@field Date string The date associated with the file.
---@field Time string The time associated with the file.
---@field Type FileTypeFlags The type of the file as a 32-bit flag.
---@field Size unsigned The size of the file in bytes.
---@field SizeStr string The size of the file as a formatted string.
---@field Attributes FileAttributes|unsigned The file attributes associated with the file.
---@field ExecType FileExecType The execution type associated with the file.

---@alias FilebrowserResult { Canceled: boolean, File: FileObject? }

---Displays a file browser selection UI.
---@param basePath string The base directory for the file browser.
---@param selectedItem string The initially selected item.
---@param flags unsigned Additional options for the file browser behavior.
---@return FilebrowserResult # A table containing whether the operation was canceled, and a table representing the selected file if not canceled.
---@since 0.6b
function Script.ShowFilebrowser(basePath, selectedItem, flags) end

return Script
