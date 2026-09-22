
-- ==========================================
-- AURORA WEB
-- Version 2.2
-- URL + DuckDuckGo Search
-- Automatic Video + Music Detection
-- ==========================================

scriptTitle = "Aurora Web"
scriptAuthor = "Rawad sm"
scriptVersion = 2.2
scriptDescription = "A lightweight web utility for Aurora Dashboard with URL, search, video and music downloading."
scriptIcon = "icon.png"
scriptPermissions = { "http", "filesystem" }


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

    local menu = {
        "URL",
        "SEARCH"
    }


    local result =
        Script.ShowPopupList(
            "AURORA WEB",
            "Select an option",
            menu
        )


    if result == nil or result.Canceled then
        return
    end


    local selected =
        tonumber(result.Selected.Key)


    if selected == 1 then

        OpenURL()

    elseif selected == 2 then

        SearchKeyboard()

    end

end


-- ==========================================
-- URL
-- ==========================================

function OpenURL()

    local keyboard =
        Script.ShowKeyboard(
            "AURORA WEB",
            "Enter URL:",
            "http://",
            0
        )


    if keyboard == nil or keyboard.Canceled then
        return
    end


    local url =
        keyboard.Buffer or ""


    if url == "" then

        Script.ShowMessageBox(
            "AURORA WEB",
            "URL cannot be empty.",
            "OK"
        )

        return

    end


    LoadURL(url)

end


-- ==========================================
-- LOAD URL
-- ==========================================

function LoadURL(url)

    -- ======================================
    -- GET FILE NAME
    -- ======================================

    local fileName =
        GetFileName(url)


    local extension =
        GetExtension(fileName)


    -- ======================================
    -- AUTOMATIC VIDEO DETECTION
    -- ======================================

    if IsVideoExtension(extension) then

        ShowVideoURLMenu(
            url,
            fileName
        )

        return

    end


    -- ======================================
    -- AUTOMATIC MUSIC DETECTION
    -- ======================================

    if IsMusicExtension(extension) then

        ShowMusicURLMenu(
            url,
            fileName
        )

        return

    end


    -- ======================================
    -- NORMAL URL
    -- ======================================

    local response =
        Http.Get(url)


    if response == nil then

        Script.ShowMessageBox(
            "AURORA WEB",
            "No response received.",
            "OK"
        )

        return

    end


    if response.Success == false then

        Script.ShowMessageBox(
            "AURORA WEB",
            "Could not load this URL.\n\n" ..
            "The website may require HTTPS " ..
            "or modern TLS support.",
            "OK"
        )

        return

    end


    local text =
        response.OutputData or ""


    if text == "" then

        Script.ShowMessageBox(
            "AURORA WEB",
            "Website returned no data.",
            "OK"
        )

        return

    end


    ShowURLPage(
        url,
        text
    )

end


-- ==========================================
-- GET FILE NAME
-- ==========================================

function GetFileName(url)

    local cleanURL =
        url


    -- Remove query string

    local question =
        string.find(
            cleanURL,
            "?"
        )


    if question ~= nil then

        cleanURL =
            string.sub(
                cleanURL,
                1,
                question - 1
            )

    end


    -- Remove trailing slash

    while string.sub(
        cleanURL,
        -1
    ) == "/" do

        cleanURL =
            string.sub(
                cleanURL,
                1,
                -2
            )

    end


    local fileName =
        string.match(
            cleanURL,
            "([^/]+)$"
        )


    if fileName == nil then

        return ""

    end


    return fileName

end


-- ==========================================
-- VIDEO URL MENU
-- ==========================================

function ShowVideoURLMenu(
    url,
    fileName
)

    local menu = {
        "Download Video",
        "Show URL"
    }


    local result =
        Script.ShowPopupList(
            "VIDEO FOUND",
            fileName,
            menu
        )


    if result == nil or result.Canceled then
        return
    end


    local selected =
        tonumber(
            result.Selected.Key
        )


    if selected == 1 then

        DownloadVideo(url)

    elseif selected == 2 then

        Script.ShowMessageBox(
            "VIDEO URL",
            url,
            "OK"
        )

    end

end


-- ==========================================
-- MUSIC URL MENU
-- ==========================================

function ShowMusicURLMenu(
    url,
    fileName
)

    local menu = {
        "Download Music",
        "Show URL"
    }


    local result =
        Script.ShowPopupList(
            "MUSIC FOUND",
            fileName,
            menu
        )


    if result == nil or result.Canceled then
        return
    end


    local selected =
        tonumber(
            result.Selected.Key
        )


    if selected == 1 then

        DownloadMusic(url)

    elseif selected == 2 then

        Script.ShowMessageBox(
            "MUSIC URL",
            url,
            "OK"
        )

    end

end


-- ==========================================
-- URL PAGE
-- ==========================================

function ShowURLPage(
    url,
    text
)

    local message =
        "URL:\n" ..
        url ..
        "\n\n" ..
        "Page loaded successfully.\n\n" ..
        "Received " ..
        tostring(#text) ..
        " characters."


    Script.ShowMessageBox(
        "AURORA WEB",
        message,
        "OK"
    )

end


-- ==========================================
-- DOWNLOAD VIDEO
-- ==========================================

function DownloadVideo(url)

    local fileName =
        GetFileName(url)


    local extension =
        GetExtension(fileName)


    if fileName == "" then

        Script.ShowMessageBox(
            "VIDEO DOWNLOAD",
            "Could not determine the video filename.",
            "OK"
        )

        return

    end


    if not IsVideoExtension(extension) then

        Script.ShowMessageBox(
            "VIDEO DOWNLOAD",
            "This is not a supported video file.",
            "OK"
        )

        return

    end


    -- ======================================
    -- DOWNLOAD DIRECTORY
    -- ======================================

    local downloadPath =
        "Downloads\\"


    if not FileSystem.FileExists(
        downloadPath
    ) then

        FileSystem.CreateDirectory(
            downloadPath
        )

    end


    local relativeFilePath =
        downloadPath .. fileName


    -- ======================================
    -- START DOWNLOAD
    -- ======================================

    Script.SetStatus(
        "Downloading video..."
    )

    Script.SetProgress(0)


    local response =
        Http.Get(
            url,
            relativeFilePath
        )


    if response == nil then

        Script.SetProgress(0)

        Script.ShowMessageBox(
            "VIDEO DOWNLOAD",
            "No response received.",
            "OK"
        )

        return

    end


    if response.Success ~= true then

        Script.SetProgress(0)

        Script.ShowMessageBox(
            "VIDEO DOWNLOAD",
            "Video file or URL was not found.\n\n" ..
            "Make sure the URL points directly to a video file.",
            "OK"
        )

        return

    end


    Script.SetProgress(100)

    Script.SetStatus(
        "Video download completed."
    )


    -- ======================================
    -- VERIFY OUTPUT
    -- ======================================

    local outputPath =
        response.OutputPath or ""


    if outputPath == "" then

        outputPath =
            relativeFilePath

    end


    if not FileSystem.FileExists(
        outputPath
    ) then

        Script.ShowMessageBox(
            "VIDEO DOWNLOAD",
            "Download reported success, but the file could not be found.",
            "OK"
        )

        return

    end


    -- ======================================
    -- SUCCESS
    -- ======================================

    Script.ShowMessageBox(
        "VIDEO DOWNLOAD",
        "VIDEO DOWNLOADED!\n\n" ..
        "File:\n" ..
        fileName ..
        "\n\n" ..
        "Saved at:\n" ..
        outputPath,
        "OK"
    )

end


-- ==========================================
-- DOWNLOAD MUSIC
-- ==========================================

function DownloadMusic(url)

    local fileName =
        GetFileName(url)


    local extension =
        GetExtension(fileName)


    if fileName == "" then

        Script.ShowMessageBox(
            "MUSIC DOWNLOAD",
            "Could not determine the music filename.",
            "OK"
        )

        return

    end


    if not IsMusicExtension(extension) then

        Script.ShowMessageBox(
            "MUSIC DOWNLOAD",
            "This is not a supported music file.",
            "OK"
        )

        return

    end


    -- ======================================
    -- MUSIC DIRECTORY
    -- ======================================

    local downloadPath =
        "Music\\"


    if not FileSystem.FileExists(
        downloadPath
    ) then

        FileSystem.CreateDirectory(
            downloadPath
        )

    end


    local relativeFilePath =
        downloadPath .. fileName


    -- ======================================
    -- START DOWNLOAD
    -- ======================================

    Script.SetStatus(
        "Downloading music..."
    )

    Script.SetProgress(0)


    local response =
        Http.Get(
            url,
            relativeFilePath
        )


    if response == nil then

        Script.SetProgress(0)

        Script.ShowMessageBox(
            "MUSIC DOWNLOAD",
            "No response received.",
            "OK"
        )

        return

    end


    if response.Success ~= true then

        Script.SetProgress(0)

        Script.ShowMessageBox(
            "MUSIC DOWNLOAD",
            "Music file or URL was not found.\n\n" ..
            "Make sure the URL points directly to an audio file.",
            "OK"
        )

        return

    end


    Script.SetProgress(100)

    Script.SetStatus(
        "Music download completed."
    )


    -- ======================================
    -- VERIFY OUTPUT
    -- ======================================

    local outputPath =
        response.OutputPath or ""


    if outputPath == "" then

        outputPath =
            relativeFilePath

    end


    if not FileSystem.FileExists(
        outputPath
    ) then

        Script.ShowMessageBox(
            "MUSIC DOWNLOAD",
            "Download reported success, but the file could not be found.",
            "OK"
        )

        return

    end


    -- ======================================
    -- SUCCESS
    -- ======================================

    Script.ShowMessageBox(
        "MUSIC DOWNLOAD",
        "MUSIC DOWNLOADED!\n\n" ..
        "File:\n" ..
        fileName ..
        "\n\n" ..
        "Saved at:\n" ..
        outputPath,
        "OK"
    )

end


-- ==========================================
-- GET EXTENSION
-- ==========================================

function GetExtension(fileName)

    local extension =
        string.match(
            fileName,
            "%.([^%.]+)$"
        )


    if extension == nil then

        return ""

    end


    return string.lower(
        extension
    )

end


-- ==========================================
-- VIDEO EXTENSIONS
-- ==========================================

function IsVideoExtension(extension)

    if extension == "mp4" then
        return true
    end

    if extension == "mkv" then
        return true
    end

    if extension == "avi" then
        return true
    end

    if extension == "wmv" then
        return true
    end

    if extension == "mov" then
        return true
    end

    if extension == "webm" then
        return true
    end

    return false

end


-- ==========================================
-- MUSIC EXTENSIONS
-- ==========================================

function IsMusicExtension(extension)

    if extension == "mp3" then
        return true
    end

    if extension == "wav" then
        return true
    end

    if extension == "ogg" then
        return true
    end

    if extension == "flac" then
        return true
    end

    if extension == "m4a" then
        return true
    end

    if extension == "aac" then
        return true
    end

    return false

end


-- ==========================================
-- SEARCH KEYBOARD
-- ==========================================

function SearchKeyboard()

    local keyboard =
        Script.ShowKeyboard(
            "AURORA WEB SEARCH",
            "Enter search:",
            "",
            0
        )


    if keyboard == nil or keyboard.Canceled then
        return
    end


    local query =
        keyboard.Buffer or ""


    if query == "" then

        Script.ShowMessageBox(
            "WEB SEARCH",
            "Search cannot be empty.",
            "OK"
        )

        return

    end


    SearchWeb(query)

end


-- ==========================================
-- SEARCH WEB
-- ==========================================

function SearchWeb(query)

    local encoded =
        Http.UrlEncode(query)


    local url =
        "https://html.duckduckgo.com/html/?q=" ..
        encoded


    local response =
        Http.Get(url)


    if response == nil then

        Script.ShowMessageBox(
            "WEB SEARCH",
            "No response received from DuckDuckGo.",
            "OK"
        )

        return

    end


    if response.Success == false then

        Script.ShowMessageBox(
            "WEB SEARCH",
            "DuckDuckGo search failed.",
            "OK"
        )

        return

    end


    local html =
        response.OutputData or ""


    if html == "" then

        Script.ShowMessageBox(
            "WEB SEARCH",
            "DuckDuckGo returned no data.",
            "OK"
        )

        return

    end


    local results =
        ExtractResults(html)


    if #results == 0 then

        Script.ShowMessageBox(
            "WEB SEARCH",
            "Search successful!\n\n" ..
            "Received " ..
            tostring(#html) ..
            " characters.\n\n" ..
            "No links were found in the result.",
            "OK"
        )

        return

    end


    ShowResultPages(
        results,
        query
    )

end


-- ==========================================
-- EXTRACT RESULTS
-- ==========================================

function ExtractResults(html)

    local results = {}


    for href, title in string.gmatch(
        html,
        '<a[^>]-href="([^"]+)"[^>]-class="result__a"[^>]*>(.-)</a>'
    ) do

        AddResult(
            results,
            href,
            title
        )

    end


    if #results == 0 then

        for href, title in string.gmatch(
            html,
            '<a[^>]-class="result__a"[^>]-href="([^"]+)"[^>]*>(.-)</a>'
        ) do

            AddResult(
                results,
                href,
                title
            )

        end

    end


    return results

end


-- ==========================================
-- ADD RESULT
-- ==========================================

function AddResult(
    results,
    href,
    title
)

    if href == nil or title == nil then
        return
    end


    local link =
        href


    local encodedLink =
        string.match(
            link,
            "[?&]uddg=([^&]+)"
        )


    if encodedLink ~= nil then

        local decoded =
            Http.UrlDecode(
                encodedLink
            )


        if decoded ~= nil and
           decoded ~= "" then

            link =
                decoded

        end

    end


    title =
        string.gsub(
            title,
            "<[^>]+>",
            ""
        )


    title =
        string.gsub(
            title,
            "&amp;",
            "&"
        )


    title =
        string.gsub(
            title,
            "&quot;",
            "\""
        )


    title =
        string.gsub(
            title,
            "&#x27;",
            "'"
        )


    title =
        string.gsub(
            title,
            "&lt;",
            "<"
        )


    title =
        string.gsub(
            title,
            "&gt;",
            ">"
        )


    title =
        string.gsub(
            title,
            "^%s+",
            ""
        )


    title =
        string.gsub(
            title,
            "%s+$",
            ""
        )


    if title ~= "" and
       link ~= "" then

        table.insert(
            results,
            {
                Title = title,
                Link = link
            }
        )

    end

end


-- ==========================================
-- RESULT PAGES
-- ==========================================

function ShowResultPages(
    results,
    query
)

    local page = 1

    local perPage = 4


    while true do

        local startIndex =
            ((page - 1) * perPage) + 1


        local endIndex =
            startIndex + perPage - 1


        if endIndex > #results then

            endIndex =
                #results

        end


        local menu = {}

        local websiteCount = 0


        for i = startIndex, endIndex do

            local title =
                results[i].Title


            if title == nil or title == "" then

                title =
                    results[i].Link

            end


            table.insert(
                menu,
                title
            )


            websiteCount =
                websiteCount + 1

        end


        local nextIndex = 0


        if endIndex < #results then

            nextIndex =
                websiteCount + 1


            table.insert(
                menu,
                "Next"
            )

        end


        local backIndex =
            websiteCount + 1


        if nextIndex ~= 0 then

            backIndex =
                backIndex + 1

        end


        table.insert(
            menu,
            "Back"
        )


        local newSearchIndex =
            backIndex + 1


        table.insert(
            menu,
            "New Search"
        )


        local result =
            Script.ShowPopupList(
                "SEARCH: " .. query,
                "Select a website",
                menu
            )


        if result == nil or result.Canceled then
            return
        end


        local selectedIndex =
            tonumber(
                result.Selected.Key
            )


        if selectedIndex == nil then
            return
        end


        if nextIndex ~= 0 and
           selectedIndex == nextIndex then

            page =
                page + 1


        elseif selectedIndex ==
               backIndex then

            if page > 1 then

                page =
                    page - 1

            else

                return

            end


        elseif selectedIndex ==
               newSearchIndex then

            SearchKeyboard()

            return


        elseif selectedIndex >= 1 and
               selectedIndex <= websiteCount then

            local realIndex =
                startIndex +
                selectedIndex -
                1


            ShowWebsite(
                results[realIndex]
            )

        end

    end

end


-- ==========================================
-- WEBSITE
-- ==========================================

function ShowWebsite(result)

    local menu = {
        "Open URL",
        "Show URL"
    }


    local selection =
        Script.ShowPopupList(
            "WEBSITE",
            result.Title,
            menu
        )


    if selection == nil or
       selection.Canceled then

        return

    end


    local selected =
        tonumber(
            selection.Selected.Key
        )


    if selected == 1 then

        LoadURL(
            result.Link
        )


    elseif selected == 2 then

        Script.ShowMessageBox(
            "WEBSITE URL",
            result.Link,
            "OK"
        )

    end

end