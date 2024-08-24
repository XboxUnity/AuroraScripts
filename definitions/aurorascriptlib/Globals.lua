---@meta

--
-- Required Script Metadata for all Aurora Scripts
--

scriptTitle                = ""  ---@type string The title of the script.
scriptAuthor               = ""  ---@type string The author of the script.
scriptVersion              = 1   ---@type integer The version of the script as an integer. Note: Only integer values are allowed, no decimals.
scriptDescription          = ""  ---@type string A brief description of what the script does.
scriptIcon                 = ""  ---@type string? Optional. The path to the script icon file, relative to the script base path, using Windows-style escaped backslashes (e.g., "images\\icon.xur"). Valid file types are XUR and PNG.
scriptPermissions          = {}  ---@type LibModulesPrivileged[]? Optional. A list of permissions required by the script if it uses modules with restricted permissions. Defaults to {}.
scriptMinimumAuroraVersion = 0.6 ---@type number? Optional. The minimum version of Aurora that the script is compatible with. Defaults to 0.6.


--
-- Global functions and objects that are available to all scripts.
--

---Prints a message to the script log.
---@param message string The message to print.
---@since 0.6b
function print(message) end

---Prints a table to the script log.
---@param table table The table to print.
---@since 0.6b
function tprint(table) end

---Outputs the current line of execution in a script, including the script source and line number.
---@param message any The message to be logged.
---@since 0.6b
function trace(message) end

---Dumps the current Lua stack to the log, including all values and their types.
---@return integer # The number of elements in the stack.
---@since 0.6b
function stackdump() end

---Creates an immutable table representing an enumeration.
---@param enumTable EnumTable The table to convert into an enum. Keys should be strings and values integers.
---@return EnumTable enumTable The created enum table with read-only properties.
---@since 0.6b
function enum(enumTable) end

---Waits for the specified number of milliseconds.
---@param milliseconds unsigned The number of milliseconds to wait.
---@since 0.6b
function wait(milliseconds) end

---Converts an integer to an unsigned integer.
---@param value integer The integer value to convert.
---@return unsigned value The value as an unsigned integer.
---@since 0.6b
function tounsigned(value) end


--
-- Global objects used primarily by Content Scripts (Filters, Sorts, Subtitles).
--

---A global object used to store all game list Filter Categories.
GameListFilterCategories = {}

---A global object used to store all game list Sorters.
GameListSorters = {}

---A global object used to store all game list Subtitles.
GameListSubtitles = {}
