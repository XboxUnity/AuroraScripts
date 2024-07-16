-- Enum used for setting type
KeyboardFlag = enum {
    Default = 0,
    Full = 1,
    Email = 2,
    Gamertag = 4,
    Phone = 8,
    IPAddress = 16,
    Numeric = 32,
    Alphabet = 64,
    Password = 128,
    Subscription = 256,
    FocusDone = 268435456,
    Highlight = 536870912
}

PopupType = enum {
    Default = 0,
    Background = 1,
    Skin = 2,
    CoverLayout = 3,
    Language = 4
}

PermissionFlag = enum {
    None = 0,
    FileManager = 256,
    View = 512,
    Settings = 1024,
    Details = 2048,
    QuickView = 4096,
    DeleteContent = 8192,
    RenameGame = 16384
}

GizmoCommand = enum {
    A = 1,
    X = 2,
    Y = 3
}

XuiMessage = enum {
    Unknown = 0,
    Init = 1,
    Close = 2,
    Press = 3,
    Timer = 4,
    KeyDown = 5,
    KeyUp = 6,
    SelChanged = 7,
    Keyboard = 8,
    Passcode = 9,
    Msgbox = 10,
    Command = 11
};

XuiObject = enum {
    Element = 0,
    Text = 1,
    Image = 2,
    Control = 3,
    Button = 4,
    RadioButton = 5,
    RadioGroup = 6,
    Label = 7,
    Edit = 8,
    List = 9,
    Scene = 10,
    TabScene = 11,
    ProgressBar = 12,
    Slider = 13,
    Checkbox = 14
};
