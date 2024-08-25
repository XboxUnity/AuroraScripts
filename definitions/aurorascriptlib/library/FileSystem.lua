---@meta

---Provides an interface for performing file system operations, including file and directory manipulation, partition management, and installation routines.
---
---This module requires the `filesystem` permission to be enabled in the calling script's global `ScriptInfo` table.
---
---### Example
---
---```lua
---ScriptInfo = {
---  -- ...(other fields),
---  Permissions = { "filesystem" }
---}
---```
---@class FileSystem
FileSystem = {}

---Represents the state change reasons used in progress callback routines.
---Equivalent to the CopyFileEx `CALLBACK_X` state change values defined in `winbase.h`.
---@enum FileSystemCallbackReason
FileSystemCallbackReason = {
    ChunkFinished = 0x00000000, --- A chunk of data has been successfully transferred.
    StreamSwitch  = 0x00000001, --- The stream is switching to a new source.
}

---@alias FileSystemProgressReturnCode FileSystemProgressReturnCode

---Callback function type used to track the progress of a file copy or move operation.
---The function receives the total size of the file being processed and the number of bytes transferred so far.
---The function should return a `FileSystemProgressReturnCode` to control the continuation of the operation.
---@alias FileSystemProgressRoutine fun(totalFileSize: number, totalBytesTransferred: number): FileSystemProgressReturnCode

---Callback function type used to track the progress of an SVOD installation operation.
---The function receives the total size of the installation, bytes transferred, chunk information, and a callback reason.
---The function should return a `FileSystemProgressReturnCode` to control the continuation of the operation.
---@alias FileSystemSvodProgressRoutine fun(totalFileSize: number, totalBytesTransferred: number, chunkFileSize: number, chunkBytesTransferred: number, chunkNumber: unsigned, chunkTotal: unsigned, callbackReason: FileSystemCallbackReason): FileSystemProgressReturnCode

---Installs a title from disc to the specified virtual target path, optionally creating content directories and providing progress updates.
---@param virtualTargetPath string The virtual target path where the title should be installed.
---@param createContentDirs boolean Whether to create content directories.
---@param progressRoutine? FileSystemSvodProgressRoutine Optional. A callback function that receives progress updates.
---@return boolean # True if the installation was successful, false otherwise.
---@since 0.6b
function FileSystem.InstallTitleFromDisc(virtualTargetPath, createContentDirs, progressRoutine) end

---Copies a directory from source to destination, optionally overwriting existing files and providing progress updates.
---If the destination directory does not exist, it will be created.
---@param srcDirPath string The source directory path.
---@param destDirPath string The destination directory path.
---@param overwrite boolean Whether to overwrite existing files in the destination directory.
---@param progressRoutine? FileSystemProgressRoutine Optional. A callback function that receives progress updates.
---@return boolean # True if the directory copy was successful, false otherwise.
---@since 0.6b
function FileSystem.CopyDirectory(srcDirPath, destDirPath, overwrite, progressRoutine) end

---Moves a directory from source to destination, optionally overwriting existing files and providing progress updates.
---If the destination directory does not exist, it will be created.
---@param srcDirPath string The source directory path.
---@param destDirPath string The destination directory path.
---@param overwrite boolean Whether to overwrite existing files in the destination directory.
---@param progressRoutine? FileSystemProgressRoutine Optional. A callback function that receives progress updates.
---@return boolean # True if the directory move was successful, false otherwise.
---@since 0.6b
function FileSystem.MoveDirectory(srcDirPath, destDirPath, overwrite, progressRoutine) end

---Copies a file from source to destination, optionally overwriting the destination file and providing progress updates.
---If the destination path does not exist, it will be created.
---@param srcFilePath string The source file path.
---@param destFilePath string The destination file path.
---@param overwrite boolean Whether to overwrite the existing file in the destination path.
---@param progressRoutine? FileSystemProgressRoutine Optional. A callback function that receives progress updates.
---@return boolean # True if the file copy was successful, false otherwise.
---@since 0.6b
function FileSystem.CopyFile(srcFilePath, destFilePath, overwrite, progressRoutine) end

---Moves a file from source to destination, optionally overwriting the destination file and providing progress updates.
---If the destination path does not exist, it will be created.
---@param srcFilePath string The source file path.
---@param destFilePath string The destination file path.
---@param overwrite boolean Whether to overwrite the existing file in the destination path.
---@param progressRoutine? FileSystemProgressRoutine Optional. A callback function that receives progress updates.
---@return boolean # True if the file move was successful, false otherwise.
---@since 0.6b
function FileSystem.MoveFile(srcFilePath, destFilePath, overwrite, progressRoutine) end

---Deletes a directory and all its contents recursively.
---@param dirPath string The directory path to delete.
---@return boolean # True if the directory was successfully deleted, false otherwise.
---@since 0.6b
function FileSystem.DeleteDirectory(dirPath) end

---Creates a new directory, including any necessary parent directories.
---@param dirPath string The directory path to create.
---@return boolean # True if the directory was successfully created, false otherwise.
---@since 0.6b
function FileSystem.CreateDirectory(dirPath) end

---Deletes a file.
---@param filePath string The file path to delete.
---@return boolean # True if the file was successfully deleted, false otherwise.
---@since 0.6b
function FileSystem.DeleteFile(filePath) end

---Writes a string to a file.
---@param filePath string The file path to write.
---@param data string The data to write to the file.
---@return boolean # True if the data was successfully written to the file, false otherwise.
---@since 0.6b
function FileSystem.WriteFile(filePath, data) end

---Reads the entire contents of a file into a string.
---@param filePath string The file path to read.
---@return string|nil # The contents of the file, or nil if the file does not exist or could not be read.
---@since 0.6b
function FileSystem.ReadFile(filePath) end

---Renames a file or directory.
---@param curName string The current name of the file or directory.
---@param newName string The new name for the file or directory.
---@return boolean # True if the rename was successful, false otherwise.
---@since 0.6b
function FileSystem.Rename(curName, newName) end

---TODO: Better named `Exists`, ambiguous since it checks files and directories.
---
---Checks if a file or directory exists at the specified path.
---@param path string The file or directory path to check.
---@return boolean # True if the file or directory exists, false otherwise.
---@since 0.6b
function FileSystem.FileExists(path) end

---Gets the attributes of a file or directory.
---@param path string The file or directory path.
---@return FileAttributes|unsigned # The attributes of the file or directory.
---@since 0.6b
function FileSystem.GetAttributes(path) end

---Gets the size of a file.
---@param filePath string The file path.
---@return unsigned # The size of the file in bytes, or 0 if the file does not exist.
---@since 0.6b
function FileSystem.GetFileSize(filePath) end

---Represents a file system entry, such as a file or directory.
---Based on the `WIN32_FIND_DATA` structure defined in `winbase.h`.
---@class FileInfo
---@field Name string The name of the file or directory.
---@field Attributes FileAttributes|unsigned The file attributes.
---@field CreationTime integer The creation time of the file or directory.
---@field LastAccessTime integer The last access time of the file or directory.
---@field LastWriteTime integer The last write time of the file or directory.
---@field Size unsigned The size of the file, in bytes, or 0 for directories.

---Gets a list of files and directories at the specified path.
---@param path string The directory path to query.
---@return FileInfo[] # A table with an array of `FileInfo` entries containing information about each file or directory, or an empty table if no entries were found.
---@since 0.6b
function FileSystem.GetFilesAndDirectories(path) end

---Gets a list of files at the specified path.
---@param path string The directory path to query.
---@return FileInfo[] # A table with an array of `FileInfo` entries containing information about each file, or an empty table if no files were found.
---@since 0.6b
function FileSystem.GetFiles(path) end

---Gets a list of directories at the specified path.
---@param path string The directory path to query.
---@return FileInfo[] # A table with an array of `FileInfo` entries containing information about each directory, or an empty table if no directories were found.
---@since 0.6b
function FileSystem.GetDirectories(path) end

---Represents a mounted drive entry.
---@class DriveInfo
---@field Name string The name of the drive.
---@field MountPoint string The mount point of the drive.
---@field SystemPath string The system path of the drive.
---@field VirtualRoot string The virtual root of the drive.
---@field Serial string The serial number of the drive.

---Retrieves a list of mounted drives, optionally filtering for content drives only.
---@param contentDrivesOnly? boolean Optional. Whether to include only content drives. Default is false.
---@return DriveInfo[] # A table with an array of `DriveInfo` entries containing information about each drive, or an empty table if no drives were found.
---@since 0.6b
function FileSystem.GetDrives(contentDrivesOnly) end

---Gets the total size of a partition.
---@param driveName string The name of the drive.
---@return number|nil # The total size of the partition in bytes, or nil if it the drive is not mounted.
---@since 0.7b
function FileSystem.GetPartitionSize(driveName) end

---Gets the used space of a partition.
---@param driveName string The name of the drive.
---@return number|nil # The used space of the partition in bytes, or nil if it the drive is not mounted.
---@since 0.7b
function FileSystem.GetPartitionUsedSpace(driveName) end

---Gets the free space of a partition.
---@param driveName string The name of the drive.
---@return number|nil # The free space of the partition in bytes, or nil if it the drive is not mounted.
---@since 0.7b
function FileSystem.GetPartitionFreeSpace(driveName) end

return FileSystem
