GameListFilterCategories.User["Only Local Co-Op Games"] = function(Content)
	minco = bit32.rshift(bit32.band(Content.CapabilitiesOffline.LowPart, 0x00FF0000), 16)
	maxco = bit32.rshift(bit32.band(Content.CapabilitiesOffline.LowPart, 0xFF000000), 24)
	return ((minco > 1 or minco == 1) and (maxco > 2 or maxco == 2))
end