---@meta

---Provides an interface for interacting with an SQLite database instance.
---
---This module requires the `sql` permission to be enabled in the calling script's global `ScriptInfo` table.
---
---### Example
---
---```lua
---ScriptInfo = {
---  -- ...(other fields),
---  Permissions = { "sql" }
---}
---```
---@class Sql
Sql = {}

---Executes an SQL query.
---@param query string The SQL query to execute.
---@return boolean # True if the query was successfully executed, false otherwise.
---@since 0.6b
function Sql.Execute(query) end

---@alias SqlResultSet table<integer, table<string, any>> A table where each entry represents a row in the result set, and each row is a table of column name-value pairs

---Executes an SQL query and returns the result set as a table of rows.
---@param query string The SQL query to execute.
---@return SqlResultSet|nil # A table representing the result set, or nil if the query failed.
---@since 0.6b
function Sql.ExecuteFetchRows(query) end

return Sql
