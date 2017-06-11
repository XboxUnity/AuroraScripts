scriptTitle = "Network Speed Test";
scriptAuthor = "saywaking";
scriptVersion = 1;
scriptDescription = "Check your Network Speed";
scriptIcon = "icon\\icon.xur";
scriptPermissions = { "http", "filesystem" };

require("AuroraUI");
require("helper\\helper");
resultGizmo = require("GizmoResult");
optionGizmo = require("GizmoOption");

-- default Options
local options = { ["additionalInfoTest"] = { ["localIp"]  = true,
                                             ["remoteIp"] = true,
                                             ["serverIp"] = true},
                  ["pingJitterHopsTest"] = true,
                  ["downloadTest"]       = { ["enabled"] = true,
                                             ["count"]   = 2,
                                             ["url"]     = "http://scope.avm.de/zackAVM2015_Test/50MB.data",
                                             ["path"]    = "data\\downloadData.data" },
                  ["uploadTest"]         = { ["enabled"] = true,
                                             ["count"]   = 4,
                                             ["url"]     = "http://scope.avm.de/zackAVM2015/upload_2015.php",
                                             ["path"]    = "data\\uploadData.txt" }};
-- default Results
local results = { ["localIp"]         = "n/a",
                  ["remoteIp"]        = "n/a",
                  ["serverIp"]        = "n/a",
                  ["hops"]            = "n/a",
                  ["ping"]            = { ["min"]  = "n/a",
                                          ["avg"]  = "n/a",
                                          ["max"]  = "n/a",
                                          ["mdev"] = "n/a" },
                  ["jitter"]          = "n/a",
                  ["downstreamInBPS"] = 0,
                  ["upstreamInBPS"]   = 0};
            
function main()  
  if isInitSuccessful() then
    local selection = Script.ShowMessageBox("Attention", 
                                            "This Script will download a file to determine you Network speed. \n" ..
                                            "Depending on your Network Connection Speed, this can take up to 10 Minutes. \n\n" ..
                                            "To get reliable results, please stop any other Network Traffic. \n\n" .. 
                                            "Please be patient!", 
                                            "Accept", 
                                            "Abort");
                                            
    if selection.Button == 1 and optionGizmo.run(options).Result == "continue" then
      if options.additionalInfoTest.localIp then
        determineLocalIp();
      end
      if options.additionalInfoTest.remoteIp then
        determineRemoteIp();
      end
      if options.additionalInfoTest.serverIp then
        determineServerIp();
      end
      if options.pingJitterHopsTest then
        determinePingJitterHops();
      end
      if options.downloadTest.enabled then
        determineDownloadSpeed();
      end
      if options.uploadTest.enabled then
        determineUploadSpeed();
      end
      
      Script.SetStatus( "Displaying Results...");
      Script.SetProgress( 99 );
      
      resultGizmo.run( results );
    end
    
    Script.SetStatus( "Script Finished...");
    Script.SetProgress( 100 );
  end
end

function isInitSuccessful()
  Script.SetStatus( "Initializing script...");
  Script.SetProgress( 10 );
  
  local initSuccess = true;
  
  Script.SetStatus( "Clearing data folder...");
  FileSystem.DeleteFile(Script.GetBasePath() .. options.downloadTest.path);
  
  Script.SetStatus( "Checking Internet Connection...");
  if not Aurora.HasInternetConnection() then
    Script.SetStatus( "No Internet Connection...");
    initSuccess = false;
    
    Script.ShowMessageBox("Attention", "No Internet Connection detected!", "Close");
  end
  
  Script.SetProgress( 20 );
  
  return initSuccess;
end

function determineLocalIp()
  Script.SetStatus( "Determining Local IP...");
  results["localIp"] = Aurora.GetIPAddress();
end

function determineRemoteIp()
  Script.SetStatus( "Determining Remote IP...");
  local remoteIpData = Http.Get("http://scope.avm.de/zackAVM2015/ipaddr.php");
  
  if remoteIpData.Success then
    results["remoteIp"] = remoteIpData.OutputData:gsub("remote_adr=", "");
  end
end

function determineServerIp()
  Script.SetStatus( "Determining Server IP...");
  local serverIpData = Http.Get("http://scope.avm.de/zackAVM2015/ipaddrSRV.php");
  
  if serverIpData.Success then
    results["serverIp"] = serverIpData.OutputData:gsub("server_adr=", "");
  end
end

function determinePingJitterHops()
  Script.SetStatus( "Determining Ping-Info...");
  local data = Http.Get("http://scope.avm.de/zackAVM2015/ping2.php");

  if data.Success and data.OutputData:find("ttl=") then
    results["hops"]    = getHops(data.OutputData);
    results["ping"]    = getPing(data.OutputData);
    results["jitter"]  = getJitter();
  else
    results["ping"] = getPingAlternative();
    results["jitter"]  = getJitter();
  end
end

function getHops(data)
  local hops = 64;
  local ttl = tonumber(data:sub(
                        data:find("ttl=") + string.len("ttl="),
                        data:find("time") - 1));

  if ttl < hops then
    hops = hops - ttl + 1;
  else
    hops = ttl - hops;
  end
  
  return hops;
end

function getPing(data)
  local pingResultString = data:sub(data:find("rtt"), data:len());
  pingResultString = pingResultString:sub((pingResultString:find("=") -1), pingResultString:len());
  
  local pingMin = pingResultString:sub(
                    (pingResultString:find("=") + 1),
                    (pingResultString:find("/") - 1));
                            
  local pingAvg = pingResultString:sub(
                    (pingResultString:find("/") + 1),
                     pingResultString:find("/", (pingResultString:find("/") + 1)) - 1);
                             
  local pingMax = pingResultString:sub(
                    ((pingResultString:find(pingAvg) + tostring(pingAvg):len()) + 1), 
                      (pingResultString:find("/", 
                        ((pingResultString:find(pingAvg) + tostring(pingAvg):len()) + 1)) - 1));
                            
  local mdev = pingResultString:sub(
                ((pingResultString:find(pingMax) + tostring(pingMax):len()) + 1),
                 (pingResultString:find("ms") - 1));
                         
  return {["min"] = tonumber(pingMin),
          ["avg"] = tonumber(pingAvg),
          ["max"] = tonumber(pingMax),
          ["mdev"]= tonumber(mdev)};
end

function getPingAlternative()
  local url = "http://scope.avm.de/zackAVM2015/test.txt";
  local pingTimes = {};
  
  for i=1, 10 do
    local timeSnap = getCurrentTimeInMilliseconds();
    local httpData = Http.Get(url);
    
    if httpData.Success then
      local elapsedTime = (getCurrentTimeInMilliseconds() - timeSnap);
      pingTimes[i] = elapsedTime;
    end
  end
  
  table.sort(pingTimes);
  
  return {["min"] = pingTimes[1],
          ["avg"] = getAverage(pingTimes),
          ["max"] = pingTimes[#pingTimes]};
end

function getJitter()
  return round(((results["ping"]["max"] - results["ping"]["min"]) / 2), 3);
end

function determineDownloadSpeed()
  Script.SetStatus( "Determining Download Speed ...");
  Script.SetProgress( 30 );

  local downstreamTimes = {};
  local downloadFileSize;
  
  for i=1, options.downloadTest.count do
    Script.SetStatus( "Determining Download Speed Test " .. i .. "...");
    Script.SetProgress( Script.GetProgress() + 10);
  
    local timeSnap = getCurrentTimeInMilliseconds();
    local httpData = Http.Get(options.downloadTest.url, options.downloadTest.path);
    
    if httpData.Success then 
      local elapsedTime = (getCurrentTimeInMilliseconds() - timeSnap) / 1000;
      downloadFileSize = FileSystem.GetFileSize( Script.GetBasePath() .. options.downloadTest.path );
      downstreamTimes[i] = elapsedTime;
    end
  end
  
  table.sort(downstreamTimes);
  results["downstreamInBPS"] = downloadFileSize / downstreamTimes[1];
end

function determineUploadSpeed()
  Script.SetStatus( "Determining Upload Speed ...");
  
  local uploadData = {};
  uploadData["data"] = FileSystem.ReadFile( Script.GetBasePath() .. options.uploadTest.path );
  local uploadFileSize = FileSystem.GetFileSize( Script.GetBasePath() .. options.uploadTest.path );
  local upstreamTimes = {};
  
  for i=1, options.uploadTest.count do
    Script.SetStatus( "Determining Upload Speed Test " .. i .. "...");
    Script.SetProgress( Script.GetProgress() + 3);
    local timeSnap = getCurrentTimeInMilliseconds();
    local httpData = Http.Post(options.uploadTest.url, uploadData);
    
    if httpData.Success then
      local elapsedTime = (getCurrentTimeInMilliseconds() - timeSnap) / 1000;
      upstreamTimes[i] = elapsedTime;
    end
  end
  
  table.sort(upstreamTimes);
  results["upstreamInBPS"] = uploadFileSize / getAverage(upstreamTimes);
end