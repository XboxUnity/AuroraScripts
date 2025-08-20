scriptTitle = "A DVD Eject"
scriptAuthor = "zzahkaboom24"
scriptVersion = 1
scriptDescription = "A script to eject or close the dvd drive, adding this crucial and missing functionality."
scriptIcon = "icon.png"

function main()
    local trayState = Aurora.GetDVDTrayState();
    if trayState == 0 then
        Aurora.CloseDVDTray();
    elseif trayState ~= 0 then
        Aurora.OpenDVDTray();
    end
end
