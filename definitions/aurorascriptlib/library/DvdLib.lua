---@meta

---Provides an interface for interacting with the DVD drive on the console.
---@class Dvd
Dvd = {}

---Represents `enum DVD_TRAY_STATE` defined in xkelib.
---@enum DvdTrayState
DvdTrayState = {
    Empty   = 0,
    Closing = 1,
    Open    = 2,
    Opening = 3,
    Closed  = 4,
    Error   = 5,
}

---Gets the current state of the DVD tray.
---@return DvdTrayState # The current DVD tray state.
---@since 0.7b
function Dvd.GetTrayState() end

---Represents `enum DVD_MEDIA_TYPES` defined in xkelib.
---@enum DvdMediaTypes
DvdMediaTypes = {
    None             = 0x00,
    Xbox360Game      = 0x01,
    XboxOriginalGame = 0x02,
    Unknown          = 0x03,
    AudioDVD         = 0x04,
    MovieDVD         = 0x05,
    VideoCD          = 0x06,
    AudioCD          = 0x07,
    DataCD           = 0x08,
    HybridGameMovie  = 0x09,
    HDDVD            = 0x0A,
}

---Gets the type of media currently in the DVD drive.
---@return DvdMediaTypes # The type of media in the drive.
---@since 0.7b
function Dvd.GetMediaType() end

---Opens the DVD tray if it is not already open or opening.
---@return boolean # True if the tray was successfully opened, false otherwise.
---@since 0.7b
function Dvd.OpenTray() end

---Closes the DVD tray if it is not already closed or closing.
---@return boolean # True if the tray was successfully closed, false otherwise.
---@since 0.7b
function Dvd.CloseTray() end

return Dvd
