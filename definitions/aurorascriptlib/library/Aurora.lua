---@meta

---Provides an interface for common tasks such as retrieving Aurora version info, hashing,
---querying HAL/system status, performing basic SMC operations, and more.
---@class Aurora
Aurora = {}

---@alias VersionData { Major: unsigned, Minor: unsigned, Revision: unsigned, Type: unsigned }

---Retrieves the Dashboard version.
---@return VersionData # A table containing Major, Minor, Revision, and Type.
---@since 0.6b
function Aurora.GetDashVersion() end

---Retrieves the Skin version.
---@return VersionData # A table containing Major, Minor, Revision, and Type.
---@since 0.6b
function Aurora.GetSkinVersion() end

---Retrieves the FreeStyle Plugin version.
---@return VersionData # A table containing Major, Minor, Revision, and Type.
---@since 0.6b
function Aurora.GetFSPluginVersion() end

---Retrieves the Nova Plugin version.
---@return VersionData # A table containing Major, Minor, Revision, and Type.
---@since 0.6b
---@deprecated 0.7b
---**Deprecated**: Use [Aurora.GetFSPluginVersion](lua://Aurora.GetFSPluginVersion) instead.
function Aurora.GetNovaVersion() end

---Checks if the console has an internet connection.
---@return boolean # True if the console is connected to the internet.
---@since 0.6b
function Aurora.HasInternetConnection() end

---Retrieves the console's IP address on the local network.
---@return string # The local IP address as a string.
---@since 0.6b
function Aurora.GetIPAddress() end

---Retrieves the console's MAC address.
---@return string # The MAC address as a string.
---@since 0.6b
function Aurora.GetMACAddress() end

---@alias TimeInfo { Hour: unsigned, Minute: unsigned, Second: unsigned, Milliseconds: unsigned }

---Retrieves the current time.
---@return TimeInfo # A table containing Hour, Minute, Second, and Milliseconds.
---@since 0.6b
function Aurora.GetTime() end

---@alias DateInfo { Year: unsigned, Month: unsigned, Day: unsigned, DayOfWeek: unsigned }

---Retrieves the current date.
---@return DateInfo # A table containing Year, Month, Day, and DayOfWeek.
---@since 0.6b
function Aurora.GetDate() end

---@alias TemperatureInfo { CPU: number, GPU: number, RAM: number, MOBO: number }

---Retrieves the console's system temperatures.
---@return TemperatureInfo # A table containing CPU, GPU, RAM, and MOBO temperatures.
---@since 0.6b
function Aurora.GetTemperatures() end

---@alias MemoryInfo { Total: unsigned, Available: unsigned, Used: unsigned }

---Retrieves console's memory information.
---@return MemoryInfo # A table containing Total, Available, and Used memory.
---@since 0.6b
function Aurora.GetMemoryInfo() end

---@alias SkinInfo { Name: string, Author: string, Description: string, UpdateId: string, Revision: unsigned, CreationDate: string, Compressed: boolean, FilePath: string, ResourcePath: string }

---Retrieves information about the current skin.
---@return SkinInfo # A table containing skin info such as Name, Author, Description, etc.
---@since 0.6b
function Aurora.GetCurrentSkin() end

---@alias LanguagePackInfo { Name: string, Translator: string, FileName: string, IconPath: string, Language: string, LanguageCode: string }

---Retrieves information about the current language package.
---@return LanguagePackInfo # A table containing language info such as Name, Translator, FileName, etc.
---@since 0.6b
function Aurora.GetCurrentLanguage() end

---Represents `enum SMC_TRAY_STATE` defined in xkelib, with values adjusted for Lua (0-6).
---@enum SMCTrayState
SMCTrayState = {
    Open        = 0, --- SMC_TRAY_OPEN - 0x60
    OpenRequest = 1, --- SMC_TRAY_OPEN_REQUEST - 0x60
    Close       = 2, --- SMC_TRAY_CLOSE - 0x60
    Opening     = 3, --- SMC_TRAY_OPENING - 0x60
    Closing     = 4, --- SMC_TRAY_CLOSING - 0x60
    Unknown     = 5, --- SMC_TRAY_UNKNOWN - 0x60
    SpinUp      = 6, --- SMC_TRAY_SPINUP - 0x60
}

---Retrieves the DVD tray state.
---@return SMCTrayState # The current state of the DVD tray.
---@since 0.6b
function Aurora.GetDVDTrayState() end

---Opens the DVD tray.
---@since 0.6b
function Aurora.OpenDVDTray() end

---Closes the DVD tray.
---@since 0.6b
function Aurora.CloseDVDTray() end

---Restarts Aurora. Internally, calls `XLaunchNewImage` with the loaded executable path.
---@since 0.6b
function Aurora.Restart() end

---Hard reboots the console. Equivalent to calling `HalReturnToFirmware(FIRMWARE_REENTRY.HalRebootQuiesceRoutine)`.
---@since 0.6b
function Aurora.Reboot() end

---Shuts down the console. Equivalent to calling `HalReturnToFirmware(FIRMWARE_REENTRY.HalPowerDownRoutine)`.
---@since 0.6b
function Aurora.Shutdown() end

---Computes the SHA-1 hash of the input string.
---@param input string The string to hash.
---@return string # The SHA-1 hash as a hexadecimal string.
---@since 0.6b
function Aurora.Sha1Hash(input) end

---Computes the MD5 hash of the input string.
---@param input string The string to hash.
---@return string # The MD5 hash as a hexadecimal string.
---@since 0.6b
function Aurora.Md5Hash(input) end

---Computes the CRC32 hash of the input string.
---@param input string The string to hash.
---@return string # The CRC32 hash as a hexadecimal string.
---@since 0.6b
function Aurora.Crc32Hash(input) end

---Computes the SHA-1 hash of a file.
---@param filePath string The path to the file.
---@return string|nil # The SHA-1 hash as a hexadecimal string, or nil if the file does not exist.
---@since 0.6b
function Aurora.Sha1HashFile(filePath) end

---Computes the MD5 hash of a file.
---@param filePath string The path to the file.
---@return string|nil # The MD5 hash as a hexadecimal string, or nil if the file does not exist.
---@since 0.6b
function Aurora.Md5HashFile(filePath) end

---Computes the CRC32 hash of a file.
---@param filePath string The path to the file.
---@return string|nil # The CRC32 hash as a hexadecimal string, or nil if the file does not exist.
---@since 0.6b
function Aurora.Crc32HashFile(filePath) end

return Aurora
