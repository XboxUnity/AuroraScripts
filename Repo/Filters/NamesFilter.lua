GameListFilterCategories.NameFilter = {}
GameListFilterCategories.NameFilter["A - F"] = {}
GameListFilterCategories.NameFilter["A - F"]["A"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "A") end
GameListFilterCategories.NameFilter["A - F"]["B"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "B") end
GameListFilterCategories.NameFilter["A - F"]["C"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "C") end
GameListFilterCategories.NameFilter["A - F"]["D"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "D") end
GameListFilterCategories.NameFilter["A - F"]["E"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "E") end
GameListFilterCategories.NameFilter["A - F"]["F"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "F") end
GameListFilterCategories.NameFilter["G - L"] = {}
GameListFilterCategories.NameFilter["G - L"]["G"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "G") end
GameListFilterCategories.NameFilter["G - L"]["H"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "H") end
GameListFilterCategories.NameFilter["G - L"]["I"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "I") end
GameListFilterCategories.NameFilter["G - L"]["J"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "J") end
GameListFilterCategories.NameFilter["G - L"]["K"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "K") end
GameListFilterCategories.NameFilter["G - L"]["L"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "L") end
GameListFilterCategories.NameFilter["M - R"] = {}
GameListFilterCategories.NameFilter["M - R"]["M"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "M") end
GameListFilterCategories.NameFilter["M - R"]["N"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "N") end
GameListFilterCategories.NameFilter["M - R"]["O"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "O") end
GameListFilterCategories.NameFilter["M - R"]["P"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "P") end
GameListFilterCategories.NameFilter["M - R"]["Q"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "Q") end
GameListFilterCategories.NameFilter["M - R"]["R"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "R") end
GameListFilterCategories.NameFilter["S - X"] = {}
GameListFilterCategories.NameFilter["S - X"]["S"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "S") end
GameListFilterCategories.NameFilter["S - X"]["T"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "T") end
GameListFilterCategories.NameFilter["S - X"]["U"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "U") end
GameListFilterCategories.NameFilter["S - X"]["V"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "V") end
GameListFilterCategories.NameFilter["S - X"]["W"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "W") end
GameListFilterCategories.NameFilter["S - X"]["X"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "X") end
GameListFilterCategories.NameFilter["Y - Z"] = {}
GameListFilterCategories.NameFilter["Y - Z"]["Y"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "Y") end
GameListFilterCategories.NameFilter["Y - Z"]["Z"] = function(Content) return (string.upper(string.sub(Content.Name, 0, 1)) == "Z") end
GameListFilterCategories.NameFilter["Other"] = function(Content) return (string.match(string.sub(Content.Name, 0, 1), "[a-zA-Z]") == nil) end