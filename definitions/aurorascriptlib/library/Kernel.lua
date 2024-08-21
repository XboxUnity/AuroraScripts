---@meta

---Provides an interface for interacting with system-level kernel operations such as querying
---system information, managing hardware settings, and controlling console behavior.
---@class Kernel
Kernel = {}

---Represents `struct XBOX_KRNL_VERSION` defined in xkelib.
---@class KernelVersion
---@field Major unsigned The major version number, usually 2 for Xbox 360.
---@field Minor unsigned The minor version number, usually 0.
---@field Build unsigned The current build number, e.g., 17559.
---@field Qfe unsigned The QFE (Quick Fix Engineering) number, usually 0.

---Gets the Xbox kernel version.
---@return KernelVersion # A table containing the 4 kernel version parts (e.g., 2.0.17559.0)
---@since 0.6b
function Kernel.GetVersion() end

---@enum TiltState
TiltState = {
	Vertical = 0,
	Horizontal = 1
}

---Gets the console tilt state.
---@return TiltState # The console's tilt state.
---@since 0.6b
function Kernel.GetConsoleTiltState() end

---Gets the CPU key of the console.
---@return string|nil # The CPU key as a hexadecimal string, or nil if the key is not found.
---@since 0.6b
function Kernel.GetCPUKey() end

---Gets the DVD key of the console.
---@return string|nil # The DVD key as a hexadecimal string, or nil if the key is not found.
---@since 0.6b
function Kernel.GetDVDKey() end

---@alias MoboType "Xenon"|"Zephyr"|"Falcon"|"Jasper"|"Trinity"|"Corona"|"Winchester"|"Unknown"

---Gets the type of the motherboard.
---@return MoboType # The motherboard type as a string.
---@since 0.6b
function Kernel.GetMotherboardType() end

---@alias ConsoleType "Devkit"|"Retail"

---Gets the console type.
---@return ConsoleType # The console type as a string.
---@since 0.6b
function Kernel.GetConsoleType() end

---Gets the console ID.
---@return string # The console ID as a string.
---@since 0.6b
function Kernel.GetConsoleId() end

---Gets the console serial number.
---@return string # The console serial number as a string.
---@since 0.6b
function Kernel.GetSerialNumber() end

---Gets the CPU temperature threshold.
---@return unsigned|nil # The CPU temperature threshold, or nil if the value cannot be retrieved.
---@since 0.6b
function Kernel.GetCPUTempThreshold() end

---Gets the GPU temperature threshold.
---@return unsigned|nil # The GPU temperature threshold, or nil if the value cannot be retrieved.
---@since 0.6b
function Kernel.GetGPUTempThreshold() end

---Gets the EDRAM temperature threshold.
---@return unsigned|nil # The EDRAM temperature threshold, or nil if the value cannot be retrieved.
---@since 0.6b
function Kernel.GetEDRAMTempThreshold() end

---Sets the CPU temperature threshold.
---@param threshold unsigned The new CPU temperature threshold.
---@return boolean # True if the threshold was successfully set, false otherwise.
---@since 0.6b
function Kernel.SetCPUTempThreshold(threshold) end

---Sets the GPU temperature threshold.
---@param threshold unsigned The new GPU temperature threshold.
---@return boolean # True if the threshold was successfully set, false otherwise.
---@since 0.6b
function Kernel.SetGPUTempThreshold(threshold) end

---Sets the EDRAM temperature threshold.
---@param threshold unsigned The new EDRAM temperature threshold.
---@return boolean # True if the threshold was successfully set, false otherwise.
---@since 0.6b
function Kernel.SetEDRAMTempThreshold(threshold) end

---Sets the fan speed.
---@param fanSpeed unsigned The fan speed as a percentage (25-100). Values below 25 set the fan to AUTO mode.
---@return boolean # True if the fan speed was successfully set, false otherwise.
---@since 0.6b
function Kernel.SetFanSpeed(fanSpeed) end

---Sets the console date.
---@param year unsigned The year (2005-2025).
---@param month unsigned The month (1-12).
---@param day unsigned The day (varies by month and year).
---@return boolean # True if the date was successfully set, false otherwise.
---@since 0.6b
function Kernel.SetDate(year, month, day) end

---Sets the console time.
---@param hour unsigned The hour (0-23).
---@param minute? unsigned Optional. The minute (0-59). Defaults to 0.
---@param second? unsigned Optional. The second (0-59). Defaults to 0.
---@param millisecond? unsigned Optional. The millisecond (0-999). Defaults to 0.
---@return boolean # True if the time was successfully set, false otherwise.
---@since 0.6b
function Kernel.SetTime(hour, minute, second, millisecond) end

---Reboots the console with power down mode of `FIRMWARE_REENTRY.HalResetSMCRoutine`.
---Internally, calls `HalReturnToFirmware(0x4)`.
---@since 0.6b
function Kernel.RebootSMCRoutine() end

return Kernel
