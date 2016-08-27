scriptTitle = "Aurora Disc to GOD installer"
scriptAuthor = "Phoenix"
scriptVersion = 1
scriptDescription = "Installs the current disc as Game On Demand (GOD) on a local storage device."
scriptIcon = "icon\\icon.xur"

-- Define script permissions to enable access to libraries
scriptPermissions = { "filesystem", "content" }  

-- Define used enums
FilebrowserFlag = enum {
    ShowFiles           = 0x01,
    BaseDirAsRoot       = 0x02,
    HideCreateDir       = 0x04,
    DisableHomeDrives   = 0x08,
    DeviceSelect        = 0x10,
    SelectDirectory     = 0x20
}

NotificationType = enum {
    Information         = 0,
    System              = 1,
    Warning             = 2,
    Error               = 3,
    XAM                 = 4
}

DiscInstallerCallbackReason = enum {
	ParseStart          = 0x01,
	ParseComplete       = 0x02,
	PathsPrepared       = 0x03,
	ChunkCreate         = 0x04,
	ChunkTransfer       = 0x05,
	HashStart           = 0x06,
	HashComplete        = 0x07,
	HeaderCreated       = 0x08,
    CleanupStart        = 0x09,
    CleanupComplete     = 0x10
}

DiscInstallerReturnCommand = enum {
	Continue            = 0x01,
	Cancel              = 0x02,
	Quiet               = 0x03
}

-- Mimic a switch / case statement
function switch(value, cases)
    return cases[value]
end

-- Global states
local WasCanceled = false
local ShouldCleanup = false
local CleanupDone = false

-- Main entry point to script
function main()
    -- Don't allow abort before writing starts
    Script.SetCancelEnable(false)
    
    -- Return values
    local ret
    
    -- Initialize targetPath and createContentDir
    local targetPath = ""
    local createContentDirs = false
    
    -- Browse for install path
    ret = Script.ShowFilebrowser("\\Xbox360\\System\\", "", FilebrowserFlag.BaseDirAsRoot + FilebrowserFlag.SelectDirectory)
    
    -- Check if canceled
    if ret.Canceled == true then
        Script.ShowNotification("Disc installation canceled", NotificationType.Warning)
    else
        -- Get installation path
        local file = ret.File
        targetPath = file.VirtualRoot .. "\\" .. file.RelativePath .. "\\" .. file.Name .. "\\"
        
        -- Ask if content dirs should be created
        ret = Script.ShowMessageBox("Content directories", "Create content directories?\n\nThis will create a '<TitleID>' and '00007000' subdirectory.", "No", "Yes");
        if ret.Button == 2 then
            createContentDirs = true;
        end
        
        -- Update status
        Script.SetStatus("Preparing to install disc");
        
        -- Install the disc
        local installed = FileSystem.InstallTitleFromDisc(targetPath, createContentDirs, progressRoutine);
        
        -- Check if installation was successful
        if installed then
            -- Update status
            Script.SetStatus("Disc installed...");
            
            -- Show notification
            Script.ShowNotification("Disc installed successfully");
            
            -- Ask if content should be scanned
            ret = Script.ShowMessageBox("Scan for content", "Scan for new content now?\n\nThis will add the installed title if it is installed in a scan path location.", "No", "Yes");
            if ret.Button == 2 then
                if Content.StartScan() == true then
                    Script.ShowNotification("Content Scan started");
                else
                    Script.ShowNotification("Unable to start Content Scan", NotificationType.Warning);
                end
            end
        else
            -- Update status
            Script.SetStatus("Disc install " .. (WasCanceled and "canceled" or "failed"));
            
            -- Show notification if cleanup failed
            if ShouldCleanup ==true and CleanupComplete == false then
                Script.ShowNotification("File cleanup failed, view log for more information", NotificationType.Warning)
            end
        end
    end
end

-- Handle progress callback
function progressRoutine(totalfilesize, filesize, chunksize, totalchunksize, chunknumber, chunkcount, callbackreason)
    
    -- Define status strings
    local cases = {
        [DiscInstallerCallbackReason.ParseStart] = "Parsing disc",
        [DiscInstallerCallbackReason.ParseComplete] = "Parse complete",
        [DiscInstallerCallbackReason.PathsPrepared] = "Paths prepared",
        [DiscInstallerCallbackReason.ChunkCreate] = "DATA file created",
        [DiscInstallerCallbackReason.ChunkTransfer] = "DATA file transfering",
        [DiscInstallerCallbackReason.HashStart] = "Hash start",
        [DiscInstallerCallbackReason.HashComplete] = "Hash complete",
        [DiscInstallerCallbackReason.HeaderCreated] = "Header created",
        [DiscInstallerCallbackReason.CleanupStart] = "Cleanup start",
        [DiscInstallerCallbackReason.CleanupComplete] = "Cleanup complete"
    }
    
    -- Initialize continue
    local continue = DiscInstallerReturnCommand.Continue
    
    -- Set progressbar
    Script.SetProgress(filesize, totalfilesize);

    -- Allow abort when not parsing or cleaning up
    if callbackreason >= DiscInstallerCallbackReason.PathsPrepared and callbackreason < DiscInstallerCallbackReason.CleanupStart then
        if Script.IsCancelEnabled() == false then Script.SetCancelEnable(true) end
    else
        if Script.IsCancelEnabled() == true then Script.SetCancelEnable(false) end
    end
    
    -- Define the status text
    local stat = switch(callbackreason, cases)
    -- Add chunk number if needed
    if callbackreason >= DiscInstallerCallbackReason.ChunkCreate and callbackreason <= DiscInstallerCallbackReason.ChunkTransfer then
        stat = stat .. " [" .. tostring(chunknumber) .. "/" .. tostring(chunkcount) .. "]"
    end
    
    -- Set status text if changed
    if Script.GetStatus() ~= stat then Script.SetStatus(stat) end
    
    -- Ask for cleanup if canceled or failed
    if callbackreason == DiscInstallerCallbackReason.CleanupStart then
        
        -- Cleanup is needed
        ShouldCleanup = true
        
        -- Show notification
        Script.ShowNotification("Disc installation " .. (WasCanceled and "canceled" or "failed"),
            WasCanceled and NotificationType.Warning or NotificationType.Error);
        
        -- Allow cleanup to be canceled
        ret = Script.ShowMessageBox("Cleanup", "Cleanup files and (empty) directories?\n\nThis will attempt to delete all data files,\nthe data directory and content directories\n(if applicable).", "No", "Yes");
        if ret.Button == 1 then
            continue = DiscInstallerReturnCommand.Cancel
            
            -- Cleanup is canceled
            ShouldCleanup = false
        end
    else
        -- Cancel disc installation if Abort is pressed
        if Script.IsCanceled() then
            continue = DiscInstallerReturnCommand.Cancel
            WasCanceled = true
        end
    end

        -- Ask for cleanup if canceled or failed
    if callbackreason == DiscInstallerCallbackReason.CleanupComplete then
        
        -- Set cleanup  completed
        CleanupComplete = true
        
        -- Show notification
        Script.ShowNotification("File cleanup completed")
    end
    
    -- Return if the script should be continued
    return continue
end
