local function GetFlag(Content, flag)
	if (bit32.btest(Content.CapabilitiesFlag, flag)) then
		return "Yes"
	end
	return "No"
end

GameListSubtitles["DolbyDigitalSupported"] = function(Content)	
	return string.format("Supports Dolby Digital: %s", GetFlag(Content, 1))
end

GameListSubtitles["HarddriveRequired"] = function(Content)
	return string.format("Requires Harddrive: Offline: %s Online: %s", GetFlag(Content, 2), GetFlag(Content, 4))
end

GameListSubtitles["HarddriveRequiredOffline"] = function(Content)
	return string.format("Requires Harddrive (Offline): %s", GetFlag(Content, 2))
end

GameListSubtitles["HarddriveRequiredOnline"] = function(Content)
	return string.format("Requires Harddrive (Online): %s", GetFlag(Content, 4))
end

GameListSubtitles["OnlineLeaderBoards"] = function(Content)
	return string.format("Online Leaderboards: %s", GetFlag(Content, 8))
end

GameListSubtitles["OnlineContentDownload"] = function(Content)
	return string.format("Online Content Download: %s", GetFlag(Content, 16))
end

GameListSubtitles["OnlineVoice"] = function(Content)
	return string.format("Online Voice: %s", GetFlag(Content, 32))
end