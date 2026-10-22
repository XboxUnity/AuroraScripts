local TopLevelMenu = {}
TopLevelMenu.SubMenu = {}
local TitleText = "Menu";
local EmptyText = "No Menu Available";
local ExitOnCancel = false;
local GoBackText = "Go Back";
local SortAlphaBetically = false;

_ShowMenu = function(menuItem)
	local menu = {}
	local displayToOriginal = {} -- Maps the displayed index to the original Lua table index

	if SortAlphaBetically then
		table.sort(menuItem, function(a, b) return type(a) == "table" and type(b) == "table" and a.Name < b.Name; end);
	end

	-- Safely iterate using the highest numeric index to avoid ipairs issues when the table contains gaps
	local maxIndex = 0
	for k, _ in pairs(menuItem) do
		if type(k) == "number" and k > maxIndex then
			maxIndex = k
		end
	end

	for k = 1, maxIndex do
		local v = menuItem[k]
		if v ~= nil then
			if type(v) == "table" then
				table.insert(menu, v.Name)
				table.insert(displayToOriginal, k)
			else
				if GoBackText ~= nil and GoBackText ~= "" then
					table.insert(menu, GoBackText)
					table.insert(displayToOriginal, k)
				end
			end
		end
	end

	-- If the generated menu is empty, add a placeholder to prevent an empty list or crashes
	if #menu == 0 then
		table.insert(menu, "No Options Available")
		table.insert(displayToOriginal, 1)
	end

	local ret = Script.ShowPopupList(TitleText, EmptyText, menu);

	-- If the user canceled or selected "Go Back"
	if ret.Canceled == true or (ret.Selected.Key ~= nil and menu[ret.Selected.Key] == GoBackText) then
		if ret.Canceled == true then
			if ExitOnCancel == true then
				return nil, menuItem, ret.Canceled, nil;
			end
		end

		if menuItem.Parent == nil or menuItem.Parent.Parent == nil then
			return nil, menuItem, ret.Canceled, nil;
		else
			menu = nil;
			ret = nil;
			return _ShowMenu(menuItem.Parent.Parent);
		end
	else
		-- Use the mapping to retrieve the correct original item, preventing index mismatches
		local originalKey = displayToOriginal[ret.Selected.Key]
		if originalKey == nil then
			originalKey = ret.Selected.Key
		end

		ret = menuItem[originalKey];

		if ret.SubMenu == nil then
			return ret.Data, menuItem, false, ret;
		else
			menu = nil;
			return _ShowMenu(ret.SubMenu);
		end
	end
end

Menu = {
	ShowMenu = function(menuItem)
		return _ShowMenu(menuItem); -- Calls the modified function
	end,

	ShowMainMenu = function()
		return _ShowMenu(TopLevelMenu.SubMenu); -- Displays the main menu
	end,

	ResetMenu = function()
		TopLevelMenu.SubMenu = {} -- Clears the menu
		TitleText = "Menu"; -- Restores the default title
		EmptyText = "No Menu Available"; -- Restores the default empty message
		ExitOnCancel = false; -- Resets ExitOnCancel
		GoBackText = "Go Back"; -- Restores the default Go Back text
	end,

	MakeMenuItem = function(displayName, data)
		return {
			Name = displayName; -- Displayed menu item name
			Data = data; -- Associated data
		}
	end,

	AddSubMenuItem = function(menuItem, subMenuItem)
		if menuItem.SubMenu == nil then -- Create the submenu if it doesn't exist
			menuItem.SubMenu = {}
			menuItem.SubMenu[1] = GoBackText; -- Add "Go Back" as the first item
			menuItem.SubMenu.Parent = menuItem; -- Set submenu parent
		end

		subMenuItem.Parent = menuItem.SubMenu; -- Set submenu item parent
		table.insert(menuItem.SubMenu, subMenuItem); -- Add submenu item
	end,

	AddMainMenuItem = function(menuItem)
		if TopLevelMenu.SubMenu == nil then -- Create the main menu if necessary
			TopLevelMenu.SubMenu = {}
			TopLevelMenu.SubMenu.Parent = TopLevelMenu;
		end

		menuItem.Parent = TopLevelMenu.SubMenu;
		table.insert(TopLevelMenu.SubMenu, menuItem); -- Add main menu item
	end,

	SetTitle = function(title)
		TitleText = title;
	end,

	SetEmptyText = function(emptyText)
		EmptyText = emptyText;
	end,

	SetExitOnCancel = function(exitOnCancel)
		ExitOnCancel = exitOnCancel == true;
	end,

	SetGoBackText = function(goBackText)
		GoBackText = goBackText;
	end,

	SetSortAlphaBetically = function(sortAlphaBetically)
		SortAlphaBetically = sortAlphaBetically == true;
	end,

	IsMainMenu = function(menu)
		return menu == TopLevelMenu.SubMenu;
	end
}

return Menu;