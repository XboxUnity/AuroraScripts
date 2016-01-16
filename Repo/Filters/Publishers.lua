local function IsEaGame(Content)
	if (string.lower(string.sub(Content.Publisher, 0, 15)) == "electronic arts") then return true end
	if (string.lower(string.sub(Content.Publisher, 0, 2)) == "ea") then return true end --return (string.lower(string.sub(Content.Publisher, 3, 6)) ~= "sports") end
	return false
end

local function IsUbisoftGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 7)) == "ubisoft") end

local function IsWarnerBrosGame(Content)
	if (string.lower(string.sub(Content.Publisher, 0, 11)) == "warner bros") then return true end
	if (string.lower(string.sub(Content.Publisher, 0, 8)) == "wb games") then return true end
	if (string.lower(string.sub(Content.Publisher, 0, 15)) == "warner brothers") then return true end
	return false
end

local function IsTHQGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 3)) == "thq") end

local function IsActivisionGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 10)) == "activision") end

local function IsBandaiNamcoGame(Content)
	if (string.lower(string.sub(Content.Publisher, 0, 6)) == "bandai") then return true end
	if (string.lower(string.sub(Content.Publisher, 0, 5)) == "namco") then return true end
	return false
end

local function IsCapcomGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 6)) == "capcom") end

local function IsCodeMastersGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 11)) == "codemasters") end

local function IsKonamiGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 6)) == "konami") end

local function IsMicrosoftGame(Content)
	if (string.lower(string.sub(Content.Publisher, 0, 9)) == "microsoft") then return true end
	if (string.lower(string.sub(Content.Publisher, 0, 3)) == "mgs") then return true end
	return false
end

local function IsPopCapGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 6)) == "popcap") end

local function IsRockStarGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 8)) == "rockstar") end

local function IsSegaGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 4)) == "sega") end

local function IsSquareEnixGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 6)) == "square") end

local function IsBethesdaGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 8)) == "bethesda") end

local function IsEidosGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 5)) == "eidos") end
	
local function IsDisneyGame(Content) return (string.lower(string.sub(Content.Publisher, 0, 6)) == "disney") end

GameListFilterCategories.Publishers = {}
GameListFilterCategories.Publishers["EA"] = function(Content) return IsEaGame(Content) end
GameListFilterCategories.Publishers["Ubisoft"] = function(Content) return IsUbisoftGame(Content) end
GameListFilterCategories.Publishers["Warner Bros"] = function(Content) return IsWarnerBrosGame(Content) end
GameListFilterCategories.Publishers["THQ"] = function(Content) return IsTHQGame(Content) end
GameListFilterCategories.Publishers["Activision"] = function(Content) return IsActivisionGame(Content) end
GameListFilterCategories.Publishers["Bandai Namco"] = function(Content) return IsBandaiNamcoGame(Content) end
GameListFilterCategories.Publishers["Capcom"] = function(Content) return IsCapcomGame(Content) end
GameListFilterCategories.Publishers["Codemasters"] = function(Content) return IsCodeMastersGame(Content) end
GameListFilterCategories.Publishers["Konami"] = function(Content) return IsKonamiGame(Content) end
GameListFilterCategories.Publishers["Microsoft"] = function(Content) return IsMicrosoftGame(Content) end
GameListFilterCategories.Publishers["PopCap"] = function(Content) return IsPopCapGame(Content) end
GameListFilterCategories.Publishers["Rockstar"] = function(Content) return IsRockStarGame(Content) end
GameListFilterCategories.Publishers["Sega"] = function(Content) return IsSegaGame(Content) end
GameListFilterCategories.Publishers["Square Enix"] = function(Content) return IsSquareEnixGame(Content) end
GameListFilterCategories.Publishers["Bethesda"] = function(Content) return IsBethesdaGame(Content) end
GameListFilterCategories.Publishers["Eidos"] = function(Content) return IsEidosGame(Content) end
GameListFilterCategories.Publishers["Disney"] = function(Content) return IsDisneyGame(Content) end
