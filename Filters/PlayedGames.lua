GameListFilterCategories.User["Only Played Games"] = function(Content)
	return ((Content.LastPlayed.HighPart ~= 0) and (Content.LastPlayed.LowPart ~= 0))
end

GameListFilterCategories.User["Hide Played Games"] = function(Content)
	return ((Content.LastPlayed.HighPart == 0) and (Content.LastPlayed.LowPart == 0))
end
