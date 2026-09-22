-- ==========================================
-- AURORA TIMER
-- Version 1.0
-- ==========================================

scriptTitle = "Aurora Timer"
scriptAuthor = "Rawad sm"
scriptVersion = 1.0
scriptDescription = "Simple offline timer for Aurora Dashboard."
scriptIcon = "icon.png"

-- ==========================================
-- MAIN MENU
-- ==========================================

MainMenu = {
    "Start Timer",
    "About",
    "Exit"
}

Main_StartTimer = 1
Main_About = 2
Main_Exit = 3

-- ==========================================
-- GET NUMBER
-- ==========================================

function GetNumber(title, message)

    local result =
        Script.ShowKeyboard(
            "AURORA TIMER",
            message,
            "",
            0
        )

    if result == nil then
        return nil
    end

    if result.Canceled then
        return nil
    end

    local value =
        tonumber(
            result.Buffer or ""
        )

    if value == nil then

        Script.ShowMessageBox(
            "AURORA TIMER",
            "Invalid number.",
            "OK"
        )

        return nil

    end

    if value < 0 then

        Script.ShowMessageBox(
            "AURORA TIMER",
            "Please enter a positive number.",
            "OK"
        )

        return nil

    end

    return math.floor(value)

end

-- ==========================================
-- START TIMER
-- ==========================================

function StartTimer()

    -- ======================================
    -- HOURS
    -- ======================================

    local hours =
        GetNumber(
            "AURORA TIMER",
            "Enter hours:"
        )

    if hours == nil then
        return
    end

    -- ======================================
    -- MINUTES
    -- ======================================

    local minutes =
        GetNumber(
            "AURORA TIMER",
            "Enter minutes:"
        )

    if minutes == nil then
        return
    end

    -- ======================================
    -- SECONDS
    -- ======================================

    local seconds =
        GetNumber(
            "AURORA TIMER",
            "Enter seconds:"
        )

    if seconds == nil then
        return
    end

    -- ======================================
    -- CONVERT TO SECONDS
    -- ======================================

    local totalSeconds =
        (hours * 3600) +
        (minutes * 60) +
        seconds

    -- ======================================
    -- CHECK TIME
    -- ======================================

    if totalSeconds <= 0 then

        Script.ShowMessageBox(
            "AURORA TIMER",
            "Timer must be greater than 0 seconds.",
            "OK"
        )

        return

    end

    -- ======================================
    -- START NOTIFICATION
    -- ======================================

    Script.ShowNotification(
        "Timer started.",
        0
    )

    -- ======================================
    -- TIMER
    -- ======================================

    local remaining =
        totalSeconds

    while remaining > 0 do

        wait(1000)

        remaining =
            remaining - 1

        if Script.IsCanceled() then
            return
        end

    end

    -- ======================================
    -- FINISHED
    -- ======================================

    Script.ShowNotification(
        "Time is up!",
        0
    )

end

-- ==========================================
-- ABOUT
-- ==========================================

function ShowAbout()

    local message =
        "\n" ..
        "       AURORA TIMER" ..
        "\n\n" ..
        "       Version 1.0" ..
        "\n\n" ..
        "       Created by Rawad sm" ..
        "\n\n" ..
        "       Simple offline timer" ..
        "\n" ..
        "       for Aurora Dashboard." ..
        "\n\n"

    Script.ShowMessageBox(
        "ABOUT",
        message,
        "OK"
    )

end

-- ==========================================
-- MAIN MENU
-- ==========================================

function ShowMainMenu()

    local dialogBox =
        Script.ShowPopupList(
            scriptTitle,
            "Select an option:",
            MainMenu
        )

    if dialogBox == nil then
        return -1
    end

    if dialogBox.Canceled then
        return -1
    end

    return tonumber(
        dialogBox.Selected.Key
    )

end

-- ==========================================
-- MAIN
-- ==========================================

function main()

    local running = true

    while running do

        local selection =
            ShowMainMenu()

        -- ==================================
        -- START TIMER
        -- ==================================

        if selection == Main_StartTimer then

            StartTimer()

        -- ==================================
        -- ABOUT
        -- ==================================

        elseif selection == Main_About then

            ShowAbout()

        -- ==================================
        -- EXIT
        -- ==================================

        elseif selection == Main_Exit then

            running = false

        else

            running = false

        end

        wait(50)

    end

end