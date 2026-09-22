-- ==========================================
-- AURORA X360 NEWS
-- Version 1.2
-- Live Xbox 360 Modding News
-- Source: ConsoleMods
-- ==========================================

scriptTitle = "Aurora X360 News"
scriptAuthor = "Rawad sm"
scriptVersion = 1.2
scriptDescription = "Live Xbox 360 modding news from ConsoleMods."
scriptIcon = "icon.png"
scriptPermissions = { "http" }


-- ==========================================
-- MAIN
-- ==========================================

function main()

    Home()

end


-- ==========================================
-- HOME
-- ==========================================

function Home()

    while true do

        local menu = {
            "Latest X360 News",
            "Refresh News",
            "Open ConsoleMods",
            "About"
        }


        local result =
            Script.ShowPopupList(
                "AURORA X360 NEWS",
                "Select an option",
                menu
            )


        -- ======================================
        -- B ON HOME = EXIT SCRIPT
        -- ======================================

        if result == nil or result.Canceled then

            return

        end


        local selected =
            tonumber(
                result.Selected.Key
            )


        if selected == 1 then

            GetNews()

        elseif selected == 2 then

            GetNews()

        elseif selected == 3 then

            OpenConsoleMods()

        elseif selected == 4 then

            ShowAbout()

        end

    end

end


-- ==========================================
-- GET NEWS
-- ==========================================

function GetNews()

    Script.SetStatus(
        "Connecting to ConsoleMods..."
    )

    Script.SetProgress(0)


    local url =
        "https://consolemods.org/wiki/Xbox_360%3AScene_History"


    local response =
        Http.Get(url)


    if response == nil then

        Script.SetProgress(0)

        Script.ShowMessageBox(
            "X360 NEWS",
            "No response received from ConsoleMods.",
            "OK"
        )

        return

    end


    if response.Success ~= true then

        Script.SetProgress(0)

        Script.ShowMessageBox(
            "X360 NEWS",
            "Could not connect to ConsoleMods.\n\n" ..
            "Check your Xbox network connection.",
            "OK"
        )

        return

    end


    local html =
        response.OutputData or ""


    if html == "" then

        Script.SetProgress(0)

        Script.ShowMessageBox(
            "X360 NEWS",
            "ConsoleMods returned no data.",
            "OK"
        )

        return

    end


    Script.SetProgress(30)

    Script.SetStatus(
        "Reading Xbox 360 scene..."
    )


    local news =
        ExtractNews(html)


    Script.SetProgress(100)

    Script.SetStatus(
        "News loaded."
    )


    if #news == 0 then

        Script.ShowMessageBox(
            "X360 NEWS",
            "ConsoleMods loaded successfully,\n\n" ..
            "but no Xbox 360 news entries were detected.",
            "OK"
        )

        return

    end


    ShowNewsList(news)

end


-- ==========================================
-- EXTRACT NEWS
-- ==========================================

function ExtractNews(html)

    local news = {}


    if html == nil or html == "" then

        return news

    end


    local text =
        html


    -- ======================================
    -- HTML BREAKS
    -- ======================================

    text =
        string.gsub(
            text,
            "<br%s*/?>",
            "\n"
        )


    text =
        string.gsub(
            text,
            "</p>",
            "\n"
        )


    text =
        string.gsub(
            text,
            "</li>",
            "\n"
        )


    text =
        string.gsub(
            text,
            "</h1>",
            "\n"
        )


    text =
        string.gsub(
            text,
            "</h2>",
            "\n"
        )


    text =
        string.gsub(
            text,
            "</h3>",
            "\n"
        )


    text =
        string.gsub(
            text,
            "</tr>",
            "\n"
        )


    -- ======================================
    -- REMOVE HTML
    -- ======================================

    text =
        string.gsub(
            text,
            "<[^>]+>",
            ""
        )


    -- ======================================
    -- HTML ENTITIES
    -- ======================================

    text =
        string.gsub(
            text,
            "&amp;",
            "&"
        )


    text =
        string.gsub(
            text,
            "&quot;",
            "\""
        )


    text =
        string.gsub(
            text,
            "&#39;",
            "'"
        )


    text =
        string.gsub(
            text,
            "&#x27;",
            "'"
        )


    text =
        string.gsub(
            text,
            "&lt;",
            "<"
        )


    text =
        string.gsub(
            text,
            "&gt;",
            ">"
        )


    text =
        string.gsub(
            text,
            "&nbsp;",
            " "
        )


    -- ======================================
    -- SEARCH LINES
    -- ======================================

    for line in string.gmatch(
        text,
        "[^\n]+"
    ) do

        line =
            CleanText(line)


        if IsX360NewsLine(line) then

            AddNews(
                news,
                line
            )

        end


        if #news >= 30 then

            break

        end

    end


    return news

end


-- ==========================================
-- ADD NEWS
-- ==========================================

function AddNews(
    news,
    text
)

    if text == nil or text == "" then

        return

    end


    -- ======================================
    -- AVOID DUPLICATES
    -- ======================================

    for i = 1, #news do

        if news[i].Text == text then

            return

        end

    end


    table.insert(
        news,
        {
            Year = "XBOX 360",
            Text = text
        }
    )

end


-- ==========================================
-- CLEAN TEXT
-- ==========================================

function CleanText(text)

    if text == nil then

        return ""

    end


    text =
        string.gsub(
            text,
            "^%s+",
            ""
        )


    text =
        string.gsub(
            text,
            "%s+$",
            ""
        )


    text =
        string.gsub(
            text,
            "%s%s+",
            " "
        )


    return text

end


-- ==========================================
-- X360 NEWS FILTER
-- ==========================================

function IsX360NewsLine(line)

    if line == nil then

        return false

    end


    if #line < 15 then

        return false

    end


    local lower =
        string.lower(line)


    -- ======================================
    -- XBOX 360
    -- ======================================

    if string.find(
        lower,
        "xbox 360"
    ) ~= nil then

        return true

    end


    -- ======================================
    -- RGH
    -- ======================================

    if string.find(
        lower,
        "rgh"
    ) ~= nil then

        return true

    end


    -- ======================================
    -- JTAG
    -- ======================================

    if string.find(
        lower,
        "jtag"
    ) ~= nil then

        return true

    end


    -- ======================================
    -- AURORA
    -- ======================================

    if string.find(
        lower,
        "aurora"
    ) ~= nil then

        return true

    end


    -- ======================================
    -- XELL
    -- ======================================

    if string.find(
        lower,
        "xell"
    ) ~= nil then

        return true

    end


    -- ======================================
    -- HOMEBREW
    -- ======================================

    if string.find(
        lower,
        "homebrew"
    ) ~= nil then

        return true

    end


    -- ======================================
    -- BADUPDATE
    -- ======================================

    if string.find(
        lower,
        "badupdate"
    ) ~= nil then

        return true

    end


    -- ======================================
    -- NAND
    -- ======================================

    if string.find(
        lower,
        "nand"
    ) ~= nil then

        return true

    end


    -- ======================================
    -- DASHBOARD
    -- ======================================

    if string.find(
        lower,
        "dashboard"
    ) ~= nil then

        return true

    end


    return false

end


-- ==========================================
-- NEWS LIST
-- ==========================================

function ShowNewsList(news)

    local menu = {}


    for i = 1, #news do

        local item =
            news[i]


        local title =
            item.Text


        if #title > 100 then

            title =
                string.sub(
                    title,
                    1,
                    97
                ) ..
                "..."

        end


        table.insert(
            menu,
            title
        )

    end


    -- ======================================
    -- BACK TO HOME
    -- ======================================

    table.insert(
        menu,
        "Back to Home"
    )


    local result =
        Script.ShowPopupList(
            "X360 SCENE NEWS",
            "Live ConsoleMods data",
            menu
        )


    -- ======================================
    -- B IN NEWS = HOME
    -- ======================================

    if result == nil or result.Canceled then

        return

    end


    local selected =
        tonumber(
            result.Selected.Key
        )


    if selected == nil then

        return

    end


    -- ======================================
    -- BACK TO HOME
    -- ======================================

    if selected == #menu then

        return

    end


    -- ======================================
    -- OPEN NEWS
    -- ======================================

    if selected >= 1 and
       selected <= #news then

        ShowNewsItem(
            news[selected]
        )

        -- After reading the news,
        -- return directly to Home.

        return

    end

end


-- ==========================================
-- NEWS ITEM
-- ==========================================

function ShowNewsItem(item)

    if item == nil then

        return

    end


    local message =
        "XBOX 360 SCENE\n\n" ..
        item.Text


    Script.ShowMessageBox(
        "X360 NEWS",
        message,
        "OK"
    )

end


-- ==========================================
-- OPEN CONSOLEMODS
-- ==========================================

function OpenConsoleMods()

    local url =
        "https://consolemods.org/wiki/Xbox_360%3AScene_History"


    Script.ShowMessageBox(
        "CONSOLEMODS",
        "Xbox 360 Scene History\n\n" ..
        url,
        "OK"
    )

end


-- ==========================================
-- ABOUT
-- ==========================================

function ShowAbout()

    local message =
        "AURORA X360 NEWS\n\n" ..
        "Version: 1.2\n" ..
        "Author: Rawad sm\n\n" ..
        "Live Xbox 360 modding information.\n\n" ..
        "Source:\n" ..
        "ConsoleMods.org\n\n" ..
        "News are NOT stored locally."


    Script.ShowMessageBox(
        "ABOUT",
        message,
        "OK"
    )

end