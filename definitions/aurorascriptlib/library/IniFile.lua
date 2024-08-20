---@meta

---Provides an interface for reading and writing INI files.
---@class IniFile
IniFile = {}

---Loads an INI file from the specified path. If the file does not exist, it will be created.
---@param filePath string The path to the INI file, relative to the script base path.
---@return IniFileUserData|nil # A `userdata` object representing the loaded INI file, or nil if the file could not be loaded.
---@since 0.6b
function IniFile.LoadFile(filePath) end

---Loads an INI file from a string containing INI data.
---@param fileData string The string containing INI data.
---@return IniFileUserData|nil # A `userdata` object representing the loaded INI data, or nil if the data could not be loaded.
---@since 0.6b
function IniFile.LoadString(fileData) end

---Represents the `userdata` object returned by IniFile methods.
---@class IniFileUserData
local IniFileUserData = {}

---Reads a value from the INI file, returning the default value if the key is not found.
---@param section string The section to read from.
---@param key string The key to read.
---@param default string The default value if the key is not found.
---@return string # The value associated with the key.
---@since 0.6b
function IniFileUserData:ReadValue(section, key, default) end

---Writes a value to the INI file.
---@param section string The section to write to.
---@param key string The key to write.
---@param value string The value to write.
---@return boolean # True if the operation was successful, false otherwise.
---@since 0.6b
function IniFileUserData:WriteValue(section, key, value) end

---Retrieves all sections in the INI file.
---@return table|nil # A table containing all sections in the INI file, or nil if there are no sections.
---@since 0.6b
function IniFileUserData:GetAllSections() end

---Retrieves all keys from the specified section in the INI file.
---@param section string The section to retrieve keys from.
---@return table|nil # A table containing all keys in the section, or nil if the section does not exist.
---@since 0.6b
function IniFileUserData:GetAllKeys(section) end

---Retrieves all key-value pairs from the specified section in the INI file.
---@param section string The section to retrieve data from.
---@return table|nil # A table containing all key-value pairs in the section, or nil if the section does not exist.
---@since 0.6b
function IniFileUserData:GetSection(section) end

return IniFile
