GameListSubtitles["OfflineCapabilities"] = function(Content)
	minsys = bit32.band(Content.CapabilitiesOffline.HighPart, 0x000000FF)
	maxsys = bit32.rshift(bit32.band(Content.CapabilitiesOffline.HighPart, 0x0000FF00), 8)
	minco = bit32.rshift(bit32.band(Content.CapabilitiesOffline.LowPart, 0x00FF0000), 16)
	maxco = bit32.rshift(bit32.band(Content.CapabilitiesOffline.LowPart, 0xFF000000), 24)
	minp = bit32.band(Content.CapabilitiesOffline.LowPart, 0x000000FF)
	maxp = bit32.rshift(bit32.band(Content.CapabilitiesOffline.LowPart, 0x0000FF00), 8)
	return string.format("Offline Players: %i-%i, %i-%i, %i-%i", minsys, maxsys, minco, maxco, minp, maxp)
end

GameListSubtitles["OfflineSystemLink"] = function(Content)
	minimum = bit32.band(Content.CapabilitiesOffline.HighPart, 0x000000FF)
	maximum = bit32.rshift(bit32.band(Content.CapabilitiesOffline.HighPart, 0x0000FF00), 8)
	return string.format("Offline System Link Players: %i-%i", minimum, maximum)
end

GameListSubtitles["OfflineCo-Op"] = function(Content)
	minimum = bit32.rshift(bit32.band(Content.CapabilitiesOffline.LowPart, 0x00FF0000), 16)
	maximum = bit32.rshift(bit32.band(Content.CapabilitiesOffline.LowPart, 0xFF000000), 24)
	return string.format("Offline Co-Op Players: %i-%i", minimum, maximum)
end

GameListSubtitles["OfflinePlayers"] = function(Content)
	minimum = bit32.band(Content.CapabilitiesOffline.LowPart, 0x000000FF)
	maximum = bit32.rshift(bit32.band(Content.CapabilitiesOffline.LowPart, 0x0000FF00), 8)
	return string.format("Offline Players: %i-%i", minimum, maximum)
end