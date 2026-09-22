-- ==========================================
-- AURORA CALCULATOR
-- Version 1.1
-- ==========================================

scriptTitle = "Aurora Calculator"
scriptAuthor = "Rawad sm"
scriptVersion = 1.1
scriptDescription = "Simple calculator using the official Aurora keyboard."
scriptIcon = "icon.png"


-- ==========================================
-- MAIN MENU
-- ==========================================

MainMenu = {
    "Calculate",
    "Exit"
}

MainMenuOption_Calculate = 1
MainMenuOption_Exit = 2


-- ==========================================
-- CALCULATOR ENGINE
-- ==========================================

function CalculateExpression(expression)

    if expression == nil then
        return nil
    end

    -- Remove spaces
    expression = string.gsub(expression, " ", "")

    -- Remove = from the end
    if string.sub(expression, -1) == "=" then
        expression = string.sub(
            expression,
            1,
            string.len(expression) - 1
        )
    end

    if expression == "" then
        return nil
    end


    -- ======================================
    -- FIND OPERATOR
    -- ======================================

    local operator = nil
    local operatorPosition = nil

    -- Search for + - * /
    -- Start from character 2 so a negative
    -- number such as -5+2 is handled better.

    for i = 2, string.len(expression) do

        local character = string.sub(
            expression,
            i,
            i
        )

        if character == "+"
        or character == "-"
        or character == "*"
        or character == "/" then

            operator = character
            operatorPosition = i
            break

        end

    end


    if operator == nil then
        return nil
    end


    -- ======================================
    -- SPLIT NUMBERS
    -- ======================================

    local firstNumber =
        string.sub(
            expression,
            1,
            operatorPosition - 1
        )

    local secondNumber =
        string.sub(
            expression,
            operatorPosition + 1
        )


    local a = tonumber(firstNumber)
    local b = tonumber(secondNumber)


    if a == nil or b == nil then
        return nil
    end


    -- ======================================
    -- CALCULATE
    -- ======================================

    local answer = nil


    if operator == "+" then

        answer = a + b

    elseif operator == "-" then

        answer = a - b

    elseif operator == "*" then

        answer = a * b

    elseif operator == "/" then

        if b == 0 then
            return "DIVIDE_BY_ZERO"
        end

        answer = a / b

    end


    if answer == nil then
        return nil
    end


    return answer

end


-- ==========================================
-- FORMAT NUMBER
-- ==========================================

function FormatNumber(number)

    if number == nil then
        return "ERROR"
    end


    if number == math.floor(number) then

        return tostring(
            math.floor(number)
        )

    end


    return tostring(number)

end


-- ==========================================
-- CALCULATE
-- ==========================================

function StartCalculation()

    -- ======================================
    -- OFFICIAL AURORA KEYBOARD
    -- ======================================

    local result =
        Script.ShowKeyboard(
            "AURORA CALCULATOR",
            "Enter calculation:",
            "",
            0
        )


    -- B / CANCEL
    if result == nil then
        return
    end


    if result.Canceled then
        return
    end


    -- ======================================
    -- GET INPUT
    -- ======================================

    local expression =
        result.Buffer or ""


    if expression == "" then

        Script.ShowMessageBox(
            "AURORA CALCULATOR",
            "No calculation entered.",
            "OK"
        )

        return

    end


    -- ======================================
    -- CALCULATE
    -- ======================================

    local answer =
        CalculateExpression(
            expression
        )


    -- ======================================
    -- DIVISION BY ZERO
    -- ======================================

    if answer == "DIVIDE_BY_ZERO" then

        Script.ShowMessageBox(
            "AURORA CALCULATOR",
            "Cannot divide by zero.",
            "OK"
        )

        return

    end


    -- ======================================
    -- INVALID EXPRESSION
    -- ======================================

    if answer == nil then

        Script.ShowMessageBox(
            "AURORA CALCULATOR",
            "Invalid calculation.\n\nExamples:\n7+7=\n10-3=\n5*4=\n20/5=",
            "OK"
        )

        return

    end


    -- ======================================
    -- FORMAT RESULT
    -- ======================================

    local formattedAnswer =
        FormatNumber(answer)


    -- ======================================
    -- FINAL RESULT
    -- ======================================

    local finalText =
        expression ..
        formattedAnswer


    -- If expression already ends with =,
    -- don't add another = before the result.

    if string.sub(expression, -1) == "=" then

        local cleanExpression =
            string.sub(
                expression,
                1,
                string.len(expression) - 1
            )

        finalText =
            cleanExpression ..
            "=" ..
            formattedAnswer

    else

        finalText =
            expression ..
            "=" ..
            formattedAnswer

    end


    Script.ShowMessageBox(
        "AURORA CALCULATOR",
        "\n" ..
        finalText ..
        "\n",
        "OK"
    )

end


-- ==========================================
-- MAIN MENU
-- B = EXIT
-- ==========================================

function ShowMainMenu()

    local dialogBox =
        Script.ShowPopupList(
            scriptTitle,
            "Select an option",
            MainMenu
        )


    -- ======================================
    -- B BUTTON
    -- ======================================

    if dialogBox == nil then
        return -1
    end


    if not dialogBox.Canceled then

        return dialogBox.Selected.Key

    end


    -- B = EXIT
    return -1

end


-- ==========================================
-- MAIN LOOP
-- ==========================================

function main()

    local running = true


    while running do

        local selectedMenuOption =
            ShowMainMenu()


        -- ==================================
        -- B = EXIT
        -- ==================================

        if selectedMenuOption == -1 then

            running = false


        elseif selectedMenuOption ==
               MainMenuOption_Calculate then

            StartCalculation()


        elseif selectedMenuOption ==
               MainMenuOption_Exit then

            running = false

        end


        wait(50)

    end

end