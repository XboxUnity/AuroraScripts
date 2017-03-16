GameListSorters["Last Played"] = function(Item1, Item2, Type)
	if (Type == SortType.Descending) then
		if ((Item1.LastPlayed.HighPart == 0) and (Item2.LastPlayed.HighPart == 0)) then
			return (string.lower(Item1.Name) > string.lower(Item2.Name))
		elseif ((Item1.LastPlayed.HighPart ~= 0) and (Item2.LastPlayed.HighPart == 0)) then
			return false
		elseif ((Item1.LastPlayed.HighPart == 0) and (Item2.LastPlayed.HighPart ~= 0)) then
			return true
		elseif (Item1.LastPlayed.HighPart ~= Item2.LastPlayed.HighPart) then
			return (Item1.LastPlayed.HighPart < Item2.LastPlayed.HighPart)
		else
			return (Item1.LastPlayed.LowPart < Item2.LastPlayed.LowPart)
		end
	else
		if ((Item1.LastPlayed.HighPart == 0) and (Item2.LastPlayed.HighPart == 0)) then
			return string.lower(Item1.Name) < string.lower(Item2.Name)
		elseif ((Item1.LastPlayed.HighPart ~= 0) and (Item2.LastPlayed.HighPart == 0)) then
			return true
		elseif ((Item1.LastPlayed.HighPart == 0) and (Item2.LastPlayed.HighPart ~= 0)) then
			return false
		elseif (Item1.LastPlayed.HighPart ~= Item2.LastPlayed.HighPart) then
			return (Item1.LastPlayed.HighPart > Item2.LastPlayed.HighPart)
		else
			return (Item1.LastPlayed.LowPart > Item2.LastPlayed.LowPart)
		end
	end
end
