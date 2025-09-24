scriptTitle = "How Long To Beat"
scriptAuthor = "MinZe"
scriptVersion = 1.0
scriptDescription = "Insert How long to beat data. (Can be removed after running it)"
scriptIcon = "icon.png"
scriptPermissions = { "sql", "filesystem" }

local function replace(str, t)
    return (str:gsub('$(%w+)', t))
end
local function split(str, sep)
    local result = {}
    for match in (str .. sep):gmatch("(.-)" .. sep) do
        table.insert(result, match)
    end
    return result
end

-- Function to split the fileStr by lines
local function splitLines(str)
    local result = {}
    for line in str:gmatch("([^\r\n]+)") do
        table.insert(result, line)
    end
    return result
end
local function insert_hltb(titleId, compMain, compPlus, comp100)
    local str =
    [=[
    INSERT INTO HowLongToBeat (TitleId,CompMain,CompPlus,Comp100) VALUES (
      '$titleId',
      '$compMain',
      '$compPlus',
      '$comp100'
    );
    ]=]

    Sql.Execute(replace(str, { titleId = titleId, compMain = compMain, compPlus = compPlus, comp100 = comp100 }))
end
local function processCSVFromString(fileStr, platform)
    local results = {}
    local lines = splitLines(fileStr)

    -- Total lines to process (excluding header)
    local totalLines = #lines - 1
    Script.SetStatus("Starting CSV processing...") -- Set initial status

    local firstLine = true                         -- To skip the header

    for i, line in ipairs(lines) do
        if Script.IsCanceled() then return end
        if firstLine then
            firstLine = false -- Skip the first line (header)
        else
            -- Split the line by comma
            local values = split(line, ",")
            -- Add them to the results table
            insert_hltb(values[1], values[2], values[3], values[4])

            -- Update progress and status
            Script.SetProgress(i - 1, totalLines)
            Script.SetStatus(string.format("Processing line %d of %d... for %s", i - 1, totalLines, platform))
        end
    end

    -- Final status update after completion
    Script.SetProgress(totalLines, totalLines)
    Script.SetStatus("CSV processing complete!")

    return results
end

function main()
    local xboxPath = Script.GetBasePath() .. "output_Xbox 360.csv";
    local xboxOgPath = Script.GetBasePath() .. "output_Xbox.csv";
    if not FileSystem.FileExists(xboxPath) then
        Script.ShowMessageBox("ERROR",
            "Xbox file doesn't exist",
            "OK");
        return;
    end
    if not FileSystem.FileExists(xboxOgPath) then
        Script.ShowMessageBox("ERROR",
            "Xbox OG file doesn't exist",
            "OK");
        return;
    end
    Script.SetStatus("Creating table...");
    Script.SetProgress(50);
    local sql = [=[
create table if not EXISTS HowLongToBeat(
  TitleId integer primary key,
  CompMain integer not null,
  CompPlus integer not null,
  Comp100 integer not null
)
]=]
    Sql.Execute("DROP TABLE IF EXISTS HowLongToBeat")
    if Sql.Execute(sql) ~= true then
        Script.ShowMessageBox("ERROR",
            "Cannot execute the script",
            "OK");
    end
    local i = 0
    if Script.IsCanceled() then return end
    processCSVFromString(FileSystem.ReadFile(xboxPath), "360")
    if Script.IsCanceled() then return end
    processCSVFromString(FileSystem.ReadFile(xboxOgPath), "OG")
    local ret = Script.ShowMessageBox("Reload Required",
        "In order for the changes to take effect you need to reload Aurora\nDo you want to reload Aurora now?", "No",
        "Yes");
    if ret.Button == 2 then
        Aurora.Restart();
    end
end
