GameListSorters["Release Date"] = function(Item1, Item2, Type)
	if Type == SortType.Descending then
		if (Item1.ReleaseDate == "" or Item2.ReleaseDate == "") or (Item1.ReleaseDate == Item2.ReleaseDate) then
			return string.lower(Item1.Name) > string.lower(Item2.Name)
		end
		return Item1.ReleaseDate > Item2.ReleaseDate
	end
	if (Item1.ReleaseDate == "" or Item2.ReleaseDate == "") or (Item1.ReleaseDate == Item2.ReleaseDate) then
		return string.lower(Item1.Name) < string.lower(Item2.Name)
	end
	return Item1.ReleaseDate < Item2.ReleaseDate
end
