# Aurora Scripts

Aurora's Lua scripting API can be used to extend the functionality of Aurora through custom community-contributed filters, sorts, subtitles, and utility scripts. The API exposes global, script, and library functions for integrating into Aurora's user interface, and accessing underlying system internals.

## Table of Contents

- [Global Functions](#global-functions)
- [Script Functions](#script-functions)
- [Library Methods](#library-methods)
  - [Aurora](#library--aurora)
  - [Content](#library--content)
  - [FileSystem](#library--filesystem)
  - [Http](#library--http)
  - [IniFile](#library--inifile)
  - [Kernel](#library--kernel)
  - [Profile](#library--profile)
  - [Settings](#library--settings)
  - [Sql](#library--sql)
  - [Thread](#library--thread)
  - [ZipFile](#library--zipfile)
  - [GizmoUI](#library--gizmoui)
- [XUI](#xui)
  - [XuiObject](#xuiobject)
    - [XuiElement](#xuielement--xuiobject)
    - [XuiText](#xuitext--xuielement--xuiobject)
    - [XuiImage](#xuiimage--xuielement--xuiobject)
    - [XuiControl](#xuicontrol--xuielement--xuiobject)
      - [XuiButton](#xuibutton--xuicontrol--xuielement--xuiobject)
      - [XuiRadioButton](#xuiradiobutton--xuicontrol--xuielement--xuiobject)
      - [XuiRadioGroup](#xuiradiogroup--xuicontrol--xuielement--xuiobject)
      - [XuiLabel](#xuilabel--xuicontrol--xuielement--xuiobject)
      - [XuiEdit](#xuiedit--xuicontrol--xuielement--xuiobject)
      - [XuiList](#xuilist--xuicontrol--xuielement--xuiobject)
      - [XuiProgressBar](#xuiprogressbar--xuicontrol--xuielement--xuiobject)
      - [XuiSlider](#xuislider--xuicontrol--xuielement--xuiobject)
      - [XuiCheckbox](#xuicheckbox--xuicontrol--xuielement--xuiobject)
      - [XuiScene](#xuiscene--xuicontrol--xuielement--xuiobject)
        - [XuiTabScene](#xuitabscene--xuiscene--xuicontrol--xuielement--xuiobject)

## Global Functions

```lua
void print( string val );
void tprint( table val );
table enum( array val );
void wait( unsigned val );
unsigned tounsigned( int val );
```

## Script Functions

```lua
void Script.SetRefreshListOnExit( bool refreshList );
void Script.FileExists( string relativePath );
void Script.CreateDirectory( string relativePath );
void Script.SetProgress( unsigned val );
void Script.SetStatus( string text );
unsigned Script.GetProgress( void );
string Script.GetStatus( void );
bool Script.IsCanceled( void );
string Script.GetBasePath( void );
void Script.ShowNotification( string message, DWORD type );
table Script.ShowKeyboard( string title, string prompt, string default, [DWORD flags] );
table Script.ShowPopupList( string title, string emptyList, table listContent );
table Script.ShowPasscode( string title, string prompt, DWORD permissionFlag );
table Script.ShowMessageBox( string title, string prompt, string button1text, [string ...]);
table Script.ShowFilebrowser( string basePath, string selectedItem, [DWORD flags] );
```

## Library Methods

### Aurora

```lua
table Aurora.GetDashVersion( void );
table Aurora.GetSkinVersion( void );
table Aurora.GetFSPluginVersion( void );
string Aurora.GetIPAddress( void );
string Aurora.GetMACAddress( void );
table Aurora.GetTime( void );
table Aurora.GetDate( void );
table Aurora.GetTemperatures( void );
table Aurora.GetMemoryInfo( void );
table Aurora.GetCurrentSkin( void );
table Aurora.GetCurrentLanguage( void );
void Aurora.OpenDVDTray( void );
void Aurora.CloseDVDTray( void );
unsigned Aurora.GetDVDTrayState( void );
bool Aurora.HasInternetConnection( void );
void Aurora.Restart( void );
void Aurora.Reboot( void );
void Aurora.Shutdown( void );
string Aurora.Sha1Hash( string input );
string Aurora.Md5Hash( string input );
string Aurora.Crc32Hash( string input );
string Aurora.Sha1HashFile( string filePath );
string Aurora.Md5HashFile( string filePath );
string Aurora.Crc32HashFile( string filePath );
```

### Content

```lua
table Content.GetInfo( DWORD contentId );
bool Content.SetTitle( DWORD contentId, string title );
bool Content.SetDescription( DWORD contentId, string description );
bool Content.SetDeveloper( DWORD contentId, string developer );
bool Content.SetPublisher( DWORD contentId, string publisher );
bool Content.SetReleaseDate( DWORD contentId, string releaseDate );
bool Content.SetAsset( string imagePath, enum assetType, [DWORD screenshotIndex]);
table Content.FindContent( DWORD titleId, [string searchText]);
```

### FileSystem

```lua
bool FileSystem.CopyDirectory( string srcDir, string dstDir, bool overwrite, [function progressRoutine] );
bool FileSystem.MoveDirectory( string srcDir, string dstDir, bool overwrite, [function progressRoutine] );
bool FileSystem.DeleteDirectory( string directory );
bool FileSystem.CreateDirectory( string directory );
bool FileSystem.CopyFile( string srcFile, string dstFile, bool overwrite, [function progressRoutine] );
bool FileSystem.MoveFile( string srcFile, string dstFile, bool overwrite, [function progressRoutine] );
bool FileSystem.DeleteFile( string srcFile );
string Filesystem.ReadFile( string srcFile );
bool FileSystem.WriteFile( string srcFile, string buffer );
bool FileSystem.FileExists( string path );
unsigned FileSystem.GetFileSize( string path );
unsigned FileSystem.GetAttributes( string path );
table FileSystem.GetDrives( [boolean contentDrivesOnly] )
table FileSystem.GetFilesAndDirectories( string path );
table FileSystem.GetFiles( string path );
table FileSystem.GetDirectories( string path );
bool FileSystem.Rename( string original, string new );
```

### Http

```lua
table Http.Get( string url, [string relativeFilePath] );
table Http.Post( string url, table postvars, [string relativeFilePath] );
string Http.UrlEncode( string input );
string Http.UrlDecode( string input );
```

### IniFile

```lua
userdata IniFile.LoadFile( string relativeFilePath );
userdata IniFile.LoadString( string fileData );
```

**Userdata Methods:**

```lua
string userdata:ReadValue( string section, string key, string default );
bool userdata:WriteValue( string section, string key, string value );
table userdata:GetAllSections( void );
table userdata:GetSection( string section );
table userdata:GetAllKeys( string section );
```

### Kernel

```lua
table Kernel.GetVersion( void );
unsigned Kernel.GetConsoleTiltState( void );
string Kernel.GetCPUKey( void );
string Kernel.GetDVDKey( void );
string Kernel.GetMotherboardType( void );
string Kernel.GetConsoleType( void );
string Kernel.GetConsoleId( void );
string Kernel.GetSerialNumber( void );
unsigned Kernel.GetCPUTempThreshold( void );
unsigned Kernel.GetGPUTempThreshold( void );
unsigned Kernel.GetEDRAMTempThreshold( void );
bool Kernel.SetFanSpeed( unsigned fanSpeed );
bool Kernel.SetCPUTempThreshold( unsigned threshold );
bool Kernel.SetGPUTempThreshold( unsigned threshold );
bool Kernel.SetEDRAMTempThreshold( unsigned threshold );
void Kernel.RebootSMCRoutine( void );
bool Kernel.SetDate(unsigned Year, unsigned Month, unsigned Day);
bool Kernel.SetTime(unsigned Hour, [unsigned Minute, unsigned Second, unsigned Millisecond]);
```

### Profile

```lua
string Profile.GetXUID( unsigned playerIndex );
string Profile.GetGamerTag( unsigned playerIndex );
unsigned Profile.GetGamerScore( unsigned playerIndex );
table Profile.GetTitleAchievement( unsigned playerIndex, unsigned titleId );
```

### Settings

```lua
table Settings.GetSystem( [string, ...] );
table Settings.GetUser( [string, ...] );
table Settings.SetSystem( string name, string value, [ string, string ...] );
table Settings.SetUser( string name, string value, [ string, string ...] );
table Settings.GetSystemOptions( string name );
table Settings.GetUserOptions( string name );
table Settings.GetOptions( string name, unsigned settingType );
```

### Sql

```lua
bool Sql.Execute( string query );
bool Sql.ExecuteFetchRows( string query );
```

### Thread

```lua
void Thread.Sleep( unsigned );
```

### ZipFile

```lua
userdata ZipFile.OpenFile( string relativeFilePath );
```

**Userdata Methods:**

```lua
bool userdata:Extract( string relativeDestDir );
```

### GizmoUI

```lua
userdata GizmoUI.CreateInstance( void );
```

**Userdata Methods:**

```lua
bool userdata:RegisterCallback( unsigned messageType, function fnCallback );
bool userdata:RegisterAnimationCallback( string namedFrame, function fnCallback );
userdata userdata:RegisterControl( unsigned objectType, string objectName );
void userdata:Dismiss( object key );
object userdata:InvokeUI( string basePath, string title, string sceneFile, [string skinFile], [table initData] );
bool userdata:SetCommandText( unsigned commandId, string text );
bool userdata:SetCommandEnabled( unsigned commandId, bool state );
bool userdata:SetTimer( unsigned timerId, unsigned timerInterval );
bool userdata:KillTimer( unsigned timerId );
bool userdata:PlayTimeline( string startFrame, string initialFrame, string endFrame, bool recurse, bool loop );
table userdata:ShowMessageBox( unsigned identifier, string title, string prompt, string button1text, [string ...]);
table userdata:ShowPasscode( unsigned identifier, string title, string prompt, DWORD permissionFlag );
table userdata:ShowKeyboard( unsigned identifier, string title, string prompt, string default, DWORD flags );
void userdata:ShowNotification( string message, DWORD type );
```

## XUI

### XuiObject

    call
    typeOf

### XuiElement : XuiObject

    GetBounds
    GetId
    PlayTimeline
    SetPosition
    SetOpacity
    SetShow
    GetPosition
    GetOpacity
    IsShown

### XuiText : XuiElement : XuiObject

    GetText
    MeasureText
    SetText

### XuiImage : XuiElement : XuiObject

    GetImagePath
    SetImagePath

### XuiControl : XuiElement : XuiObject

    GetImagePath
    IsBackButton
    IsEnabled
    IsNavButton
    PlayVisualRange
    SetEnable
    SetImagePath
    SetText

### XuiButton : XuiControl : XuiElement : XuiObject

    (none)

### XuiRadioButton : XuiControl : XuiElement : XuiObject

    (none)

### XuiRadioGroup : XuiControl : XuiElement : XuiObject

    GetCurSel
    SetCurSel

### XuiLabel : XuiControl : XuiElement : XuiObject

    (none)

### XuiEdit : XuiControl : XuiElement : XuiObject

    DeleteText
    GetCaretPosition
    GetLineCount
    GetLineIndex
    GetMaxVisibleLineCount
    GetReadOnly
    GetTextLimit
    GetTopLine
    GetVisibleLineCount
    GetVSmoothScrollEnabled
    InsertText
    SetCaretPosition
    SetTextLimit
    SetTopLine

### XuiList : XuiControl : XuiElement : XuiObject

    DeleteItems
    GetCurSel
    GetItemCheck
    GetItemCount
    GetMaxVisibleLineCount
    GetMaxLinesItemCount
    GetText
    GetTopItem
    GetVisibleItemCount
    InsertItems
    IsItemChecked
    IsItemEnabled
    IsItemVisible
    SetCurSel
    SetCurSelVisible
    SetImagePath
    SetItemCheck
    SetItemEnable
    SetText
    SetTopItem

### XuiProgressBar : XuiControl : XuiElement : XuiObject

    GetRange
    GetValue
    SetRange
    SetValue

### XuiSlider : XuiControl : XuiElement : XuiObject

    GetAccel
    GetRange
    GetStep
    GetValue
    SetAccel
    SetRange
    SetStep
    SetValue

### XuiCheckbox : XuiControl : XuiElement : XuiObject

    IsChecked
    SetCheck

### XuiScene : XuiControl : XuiElement : XuiObject

    (none)

### XuiTabScene : XuiScene : XuiControl : XuiElement : XuiObject

    CanUserTab
    EnableTabbing
    GetCount
    GetCurrentTab
    Goto
    GotoNext
    GotoPrev
