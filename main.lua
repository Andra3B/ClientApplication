if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then require("lldebugger").start() end

package.path = package.path..";./"..arg[2].."/?.lua"
dofile(arg[2].."/main.lua")