GameListSorters["TitleID"] = function(Item1, Item2, Type)
if Type == SortType.Descending then
	if Item1.TitleId == Item2.TitleId then -- Check MediaID if TitleId is the same
		return Item1.MediaId > Item2.MediaId
	end
	return Item1.TitleId > Item2.TitleId
end
if Item1.TitleId == Item2.TitleId then
	return Item1.MediaId < Item2.MediaId -- Check MediaID if TitleId is the same
end
	
	return Item1.TitleId < Item2.TitleId
end
