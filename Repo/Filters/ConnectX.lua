GameListFilterCategories.User["Only ConnectX"] = function(Content)
	return (string.lower(Content.Root) == "connx:\\")
end

GameListFilterCategories.User["Hide ConnectX"] = function(Content)
	return (string.lower(Content.Root) ~= "connx:\\")
end