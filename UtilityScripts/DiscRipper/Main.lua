scriptTitle = "Disc Ripper"
scriptAuthor = "Derf"
scriptVersion = "1.0"
scriptDescription = "Copies the contents of a disc to a folder on your Xbox 360."
scriptIcon = "icon.png"
scriptPermissions = { "filesystem" }

-- Define used enums
FilebrowserFlag = enum {
    ShowFiles           = 0x01,
    BaseDirAsRoot       = 0x02,
    HideCreateDir       = 0x04,
    DisableHomeDrives   = 0x08,
    DeviceSelect        = 0x10,
    SelectDirectory     = 0x20
}

function main()
    -- Browse for install path
    local ret = Script.ShowFilebrowser("\\Xbox360\\System\\", "", FilebrowserFlag.BaseDirAsRoot + FilebrowserFlag.SelectDirectory);
    if ret.Canceled == false then
        -- Get installation path
        basePath = ret.File.MountPoint .. "\\" .. ret.File.RelativePath .. "\\" .. ret.File.Name .. "\\";
        Script.SetStatus("Copying files...");
        local result = FileSystem.CopyDirectory("dvd:\\", basePath, true, CopyProgressRoutine);
        if result == true then
            Script.ShowNotification("Copy complete!");
        else
            Script.ShowNotification("Copy failed or was aborted");
            Script.ShowMessageBox("ERROR", "The disc copy failed or was aborted.\nReasons for this may include:\n- Operation was manually aborted.\n- Destination device was removed.\n- Destination path is too long\n- Disc has anti-copying protection via long file names or paths\n\nTry selecting a short named folder on the HDD root or ripping to a USB storage device.", "OK");
        end
    end
end

function CopyProgressRoutine( dwTotalFileSize, dwTotalBytesTransferred )
    if Script.IsCanceled() then
        Aurora.OpenDVDTray(); -- This forces the "CopyFile" and "CopyDirectory" operations to abort; credit to thenicnic
    end

    Script.SetProgress(dwTotalBytesTransferred, dwTotalFileSize);
end
