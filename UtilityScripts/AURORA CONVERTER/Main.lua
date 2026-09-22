-- ==========================================
-- AURORA CONVERTER
-- Version 1.1
-- ==========================================

scriptTitle = "Aurora Converter"
scriptAuthor = "Rawad sm"
scriptVersion = 1.1
scriptDescription = "Offline storage unit converter for Aurora Dashboard with large-number support."
scriptIcon = "icon.png"

-- ==========================================
-- SOURCE UNITS
-- ==========================================

SourceMenu = {
"Byte",
"Megabyte",
"Gigabyte",
"Terabyte"
}

Source_Byte = 1
Source_Megabyte = 2
Source_Gigabyte = 3
Source_Terabyte = 4

-- ==========================================
-- TARGET UNITS
-- ==========================================

Target_Byte = 1
Target_Megabyte = 2
Target_Gigabyte = 3
Target_Terabyte = 4

-- ==========================================
-- UNIT NAMES
-- ==========================================

function GetUnitName(unit)


if unit == Source_Byte then
    return "Byte"

elseif unit == Source_Megabyte then
    return "Megabyte"

elseif unit == Source_Gigabyte then
    return "Gigabyte"

elseif unit == Source_Terabyte then
    return "Terabyte"
end

return "Unknown"


end

-- ==========================================
-- UNIT MULTIPLIERS
-- ==========================================

function GetMultiplier(unit)


if unit == Source_Byte then
    return 1

elseif unit == Source_Megabyte then
    return 1048576

elseif unit == Source_Gigabyte then
    return 1073741824

elseif unit == Source_Terabyte then
    return 1099511627776
end

return nil


end

-- ==========================================
-- CONVERT TO BYTES
-- ==========================================

function ToBytes(value, unit)


local multiplier =
    GetMultiplier(unit)


if multiplier == nil then
    return nil
end


return value * multiplier


end

-- ==========================================
-- CONVERT FROM BYTES
-- ==========================================

function FromBytes(bytes, unit)


if unit == Target_Byte then

    return bytes

elseif unit == Target_Megabyte then

    return bytes / 1048576

elseif unit == Target_Gigabyte then

    return bytes / 1073741824

elseif unit == Target_Terabyte then

    return bytes / 1099511627776

end

return nil


end

-- ==========================================
-- FORMAT NUMBER
-- ==========================================

function FormatNumber(number)


if number == nil then
    return "ERROR"
end


-- Large numbers are displayed
-- without scientific notation.

local formatted =
    string.format(
        "%.10f",
        number
    )


formatted =
    formatted:gsub(
        "0+$",
        ""
    )


formatted =
    formatted:gsub(
        "%.$",
        ""
    )


return formatted


end

-- ==========================================
-- GET NUMBER
-- ==========================================

function GetNumber()


local result =
    Script.ShowKeyboard(
        "AURORA CONVERTER",
        "Enter the value:",
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
        "AURORA CONVERTER",
        "Invalid number.",
        "OK"
    )

    return nil

end


if value < 0 then

    Script.ShowMessageBox(
        "AURORA CONVERTER",
        "Please enter a positive number.",
        "OK"
    )

    return nil

end


return value


end

-- ==========================================
-- TARGET MENU
-- ==========================================

function ShowTargetMenu(source)


local TargetMenu = {}


if source ~= Source_Byte then
    table.insert(
        TargetMenu,
        "Byte"
    )
end


if source ~= Source_Megabyte then
    table.insert(
        TargetMenu,
        "Megabyte"
    )
end


if source ~= Source_Gigabyte then
    table.insert(
        TargetMenu,
        "Gigabyte"
    )
end


if source ~= Source_Terabyte then
    table.insert(
        TargetMenu,
        "Terabyte"
    )
end


local dialogBox =
    Script.ShowPopupList(
        "CONVERT",
        "Convert to:",
        TargetMenu
    )


if dialogBox == nil then
    return nil
end


if dialogBox.Canceled then
    return nil
end


local selected =
    tonumber(
        dialogBox.Selected.Key
    )


local index = 0


for unit = 1, 4 do

    if unit ~= source then

        index =
            index + 1


        if index == selected then

            return unit

        end

    end

end


return nil


end

-- ==========================================
-- SHOW RESULT
-- ==========================================

function ShowResult(
value,
source,
target,
result
)


local sourceName =
    GetUnitName(source)


local targetName =
    GetUnitName(target)


local message =
    "\n" ..
    "       AURORA CONVERTER" ..
    "\n\n" ..
    "       " ..
    FormatNumber(value) ..
    " " ..
    sourceName ..
    "\n\n" ..
    "              =" ..
    "\n\n" ..
    "       " ..
    FormatNumber(result) ..
    " " ..
    targetName ..
    "\n"


Script.ShowMessageBox(
    "CONVERSION RESULT",
    message,
    "OK"
)


end

-- ==========================================
-- MAIN MENU
-- ==========================================

function ShowSourceMenu()


local dialogBox =
    Script.ShowPopupList(
        scriptTitle,
        "Select source unit",
        SourceMenu
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

    -- ==================================
    -- SELECT SOURCE
    -- ==================================

    local source =
        ShowSourceMenu()


    if source == -1 then

        running = false

    else

        -- ==============================
        -- ENTER NUMBER
        -- ==============================

        local value =
            GetNumber()


        if value ~= nil then

            -- ==========================
            -- SELECT TARGET
            -- ==========================

            local target =
                ShowTargetMenu(source)


            if target ~= nil then

                -- ======================
                -- CALCULATE
                -- ======================

                local bytes =
                    ToBytes(
                        value,
                        source
                    )


                local result =
                    FromBytes(
                        bytes,
                        target
                    )


                -- ======================
                -- SHOW RESULT
                -- ======================

                ShowResult(
                    value,
                    source,
                    target,
                    result
                )

            end

        end

    end


    wait(50)

end


end
