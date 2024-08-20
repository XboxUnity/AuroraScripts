# Aurora Scripting Library - Module Definitions

Aurora's scripting library API exposes several [global objects and functions](definitions/aurorascriptlib/library/Globals.lua), and includes numerous feature-rich modules designed to extend the functionality of custom scripts by interfacing with Aurora's UI, filesystem, and system internals.

## API Reference

The included modules are available for use in all Content and Utility Scripts, and are preloaded into the Lua execution environment at runtime, eliminating the need to `require` them in your script.

Library documentation is provided as [LuaDoc](https://luals.github.io/wiki/annotations/) annotations, allowing for intellisense support and type checking when used in conjunction with the VS Code extension [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) by sumneko.

Note that these annotations are a work in progress; contributions through pull requests are welcome.

## Table of Contents

- [Library Modules](#library-modules)
  - [Sql](#sql-module)*
  - [Thread](#thread-module)
  - [ZipFile](#zipfile-module)

## Library Modules

### Sql module

Provides an interface for interacting with an SQLite database instance. See [Sql.lua](definitions/aurorascriptlib/library/Sql.lua) for detailed documentation and annotations

```lua
-- class methods
Sql.Execute(query: string): boolean
Sql.ExecuteFetchRows(query: string): SqlResultSet|nil
```

### Thread module

Someone fell asleep at the keyboard and accidentally wrote this module. See [Thread.lua](definitions/aurorascriptlib/library/Thread.lua) for detailed documentation and annotations

```lua
-- class methods
Thread.Sleep(ms: unsigned)
```

### ZipFile module

Provides an interface for opening and extracting the contents of a ZIP archive using 7-Zip. See [ZipFile.lua](definitions/aurorascriptlib/library/ZipFile.lua) for detailed documentation and annotations

```lua
-- class methods
ZipFile.OpenFile(filePath: string, [createIfNotExist: boolean]): userdata|nil

-- userdata methods
userdata:Extract(destDir: string): boolean
```

