GameListSubtitles["OnlineOfflineCapabilitiesFlag"] = function(Content)
	return string.format("Online Flag: %08X, Offline Flag: %08X%08X", Content.CapabilitiesOnline, Content.CapabilitiesOffline.HighPart, Content.CapabilitiesOffline.LowPart)
end

GameListSubtitles["OnlineCapabilities"] = function(Content)
	minmulti = bit32.rshift(bit32.band(Content.CapabilitiesOnline, 0x00FF0000), 16)
	maxmulti = bit32.rshift(bit32.band(Content.CapabilitiesOnline, 0xFF000000), 24)
	minco = bit32.band(Content.CapabilitiesOnline, 0x000000FF)
	maxco = bit32.rshift(bit32.band(Content.CapabilitiesOnline, 0x0000FF00), 8)
	return string.format("Online Players: %i-%i, %i-%i", minmulti, maxmulti, minco, maxco)
end

GameListSubtitles["OnlineMultiplayer"] = function(Content)
	minimum = bit32.rshift(bit32.band(Content.CapabilitiesOnline, 0x00FF0000), 16)
	maximum = bit32.rshift(bit32.band(Content.CapabilitiesOnline, 0xFF000000), 24)
	return string.format("Online Multiplayer: %i-%i", minimum, maximum)
end

GameListSubtitles["OnlineCo-Op"] = function(Content)
	minimum = bit32.band(Content.CapabilitiesOnline, 0x000000FF)
	maximum = bit32.rshift(bit32.band(Content.CapabilitiesOnline, 0x0000FF00), 8)
	return string.format("Online Co-Op: %i-%i", minimum, maximum)
end