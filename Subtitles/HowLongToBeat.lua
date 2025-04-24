GameListSubtitles["HowLongToBeat"] = function(Content)
    local str = string.format("HLTB Not found, Title ID: %d", Content.TitleId)
    for _, v in pairs(Sql.ExecuteFetchRows("SELECT TitleId,CompMain,CompPlus,Comp100 FROM HowLongToBeat where TitleId = "..Content.TitleId)) do
		str = string.format("How Long To Beat: Main: %dh, Main + DLC: %dh, 100%%: %dh", v.CompMain, v.CompPlus, v.Comp100)
	end
    return str
end