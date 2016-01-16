GameListSubtitles["LastPlayedDebug"] = function(Content)	
	  return string.format("Last Played LowPart: %X HighPart: %X", Content.LastPlayed.LowPart, Content.LastPlayed.HighPart)
end