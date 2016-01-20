GameListSorters["Name Grouped by Type"] = function(Item1, Item2, Type)
	if Item1.Type ~= Item2.Type then
		return Item1.Type > Item2.Type
	end
	if Type == SortType.Descending then
		return string.lower(Item1.Name) > string.lower(Item2.Name)
	end
	return string.lower(Item1.Name) < string.lower(Item2.Name)
end