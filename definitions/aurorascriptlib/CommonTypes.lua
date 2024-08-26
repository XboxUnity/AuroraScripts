---@meta

---@alias LibModules
---| "Script" Core
---| "Thread"
---| "FileSystem"
---| "Sql"
---| "Content"
---| "Aurora"
---| "Settings"
---| "Kernel"
---| "Http"
---| "Profile"
---| "GizmoUI" AuroraUI
---| "IniFile"
---| "ZipFile"

---@alias LibModulesPrivileged
---| "Http"
---| "Content"
---| "FileSystem"
---| "Settings"
---| "Sql"
---| "Kernel"

---@alias unsigned integer

---Represents the return codes from a progress callback routine.
---Equivalent to the CopyFileEx `PROGRESS_X` return codes defined in `winbase.h`.
---@enum ProgressCallbackReturnCode
ProgressCallbackReturnCode = {
    Continue = 0, --- Continue the operation.
    Cancel   = 1, --- Cancel the operation.
    Quiet    = 3, --- Continue the operation without further progress reports.
}

---Represents the attributes of a file or directory.
---Equivalent to the `FILE_ATTRIBUTE_X` values defined in `winnt.h`.
---@enum FileAttributes
FileAttributes = {
	ReadOnly    = 0x00000001, --- The file or directory is read-only.
	Hidden      = 0x00000002, --- The file or directory is hidden.
	System      = 0x00000004, --- The file or directory is a system file.
	Directory   = 0x00000010, --- The entry is a directory.
	Archive     = 0x00000020, --- The file or directory is marked for backup or removal.
	Device      = 0x00000040, --- The file or directory is a device.
	Normal      = 0x00000080, --- The file or directory has no special attributes.
	Temporary   = 0x00000100, --- The file or directory is temporary.
}
