GameListFilterCategories.User["Xbox 360 And XBLA"] = function(Content)
	if (Content.Group == ContentGroup.Xbox360) then return true end
	if (Content.Group == ContentGroup.XBLA) then return true end
	return false
end
