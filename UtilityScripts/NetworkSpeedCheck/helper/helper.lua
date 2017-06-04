function getCurrentTimeInMilliseconds()
  local timeSnap = Aurora.GetTime();
  
  return ((timeSnap.Hour   * 60 * 60 * 1000) +
          (timeSnap.Minute * 60 * 1000) +
          (timeSnap.Second * 1000) +
           timeSnap.Milliseconds)
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function getAverage(t)
  local sum = 0
  local count = 0

  for k,v in pairs(t) do
    if type(v) == 'number' then
      sum = sum + v
      count = count + 1
    end
  end

  return (sum / count)
end