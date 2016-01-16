GameListSubtitles["ReleaseDate"] = function(Content)	
	if Content.ReleaseDate ~= "" then
	  return string.format("Release Date: %s", Content.ReleaseDate )
	end
	return "Release Date:  Not Available"
end