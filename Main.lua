require("Seam.Seam")

package.loadlib("./IUP/iuplua51.dll", "luaopen_iuplua")()

if iup then
	Log.Info(Enum.LogCategory.Application, "Using IUP version: %s", iup.Version())
else
	Log.Critical(Enum.LogCategory.Application, "Failed to initialise IUP!")
	
	return
end

iup.SetGlobal("UTF8MODE", "YES")

local MainWindow = iup.dialog({iup.label{title="Hello, world!"}})
MainWindow.title = "Camera"
MainWindow.size = "HALFxHALF"

iup.Show(MainWindow)

iup.MainLoop()
iup.Close()