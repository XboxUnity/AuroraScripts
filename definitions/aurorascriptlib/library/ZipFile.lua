---@meta

---Provides an interface for opening and extracting the contents of a ZIP archive using 7-Zip.
---@class ZipFile
ZipFile = {}

---Opens a ZIP file from the specified path.
---@param filePath string The path to the ZIP file, relative to the script base path.
---@param createIfNotExist? boolean Optional. If true, creates a new ZIP file if it doesn't exist. Defaults to true.
---@return ZipFileUserData|nil # A `userdata` object representing the opened ZIP file, or nil if the file could not be opened.
---@since 0.6b
function ZipFile.OpenFile(filePath, createIfNotExist) end

---Represents the `userdata` object returned by ZipFile methods.
---@class ZipFileUserData
local ZipFileUserData = {}

---Extracts the contents of the ZIP file to the specified directory.
---@param destDir string The path to the directory where the contents will be extracted, relative to the script base path.
---@return boolean # True if the extraction was successful, false otherwise.
---@since 0.6b
function ZipFileUserData:Extract(destDir) end

return ZipFile
