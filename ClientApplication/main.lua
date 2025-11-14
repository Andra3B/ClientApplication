ffi = require("ffi")
utf8 = require("utf8")
buffer = require("string.buffer")
socket = require("socket")

Class = require("Class")

Enum = require("Enum")
require("Enums")

Log = require("Log")

Vector2 = require("Vector2")
Vector3 = require("Vector3")
Vector4 = require("Vector4")

EventDirector = require("EventDirector")

NetworkServer = require("NetworkServer")
NetworkClient = require("NetworkClient")

UserInterface = require("UserInterface")

table.new = require("table.new")
table.empty = table.new(0, 0)

table.erase = function(tab, cleanupCallback)
	for key, value in pairs(tab) do
		if cleanupCallback then
			cleanupCallback(value)
		end

		tab[key] = nil
	end
end

string.replace = function(str, from, to, with)
	if to >= #str then
		return string.sub(str, 1, from - 1)..with
	else
		return string.sub(str, 1, from - 1)..with..string.sub(str, to + 1)
	end
end

math.clamp = function(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

FFILoader = require("FFILoader")

ffmpeg = require("ffmpeg.init")

local MOUSE_INPUT_STRINGS = {
	[1] = "leftmousebutton",
	[2] = "rightmousebutton",
	[3] = "middlemousebutton",
	[4] = "firstmousebutton",
	[5] = "secondmousebutton"
}

function love.load(args)
	local width, height = love.window.getDesktopDimensions(1)
	love.window.setMode(width * 0.5, height * 0.5, {
		["fullscreen"] = false,
		["stencil"] = false,
		["resizable"] = true,
		["centered"] = true,
		["display"] = 1
	})

	UserInterface.Initialise()
	
	local MyVideo = UserInterface.Video.CreateFromFile("Assets/Videos/Ocean.mp4")
	local MyVideoFrame = UserInterface.VideoFrame.Create()
	MyVideoFrame.RelativeSize = Vector2.Create(1, 1)
	MyVideoFrame.Video = MyVideo

	MyVideoFrame.Playing = true

	UserInterface.SetRoot(MyVideoFrame)
end

function love.quit(exitCode)
	UserInterface.Deinitialise()
end

function love.update(deltaTime)
	UserInterface.Update(deltaTime)
end

function love.draw()
	love.graphics.clear(0, 0, 0, 0)

	UserInterface.Draw()

	love.graphics.present()
end

function love.focus(focused)
end

function love.resize(width, height)
	UserInterface.Refresh()
end

function love.visible(visible)
end

function love.keypressed(key, scancode)
	UserInterface.Input(Enum.InputType.Keyboard, scancode, Vector4.Create(0, 0, -1, 0))
end

function love.keyreleased(key, scancode)
	UserInterface.Input(Enum.InputType.Keyboard, scancode, Vector4.Zero)
end

function love.textinput(text)
	UserInterface.TextInput(text)
end

function love.mousemoved(x, y, dx, dy)
	UserInterface.Input(Enum.InputType.Mouse, "mousemovement", Vector4.Create(x, y, dx, dy))
end

function love.wheelmoved(dx, dy)
	UserInterface.Input(Enum.InputType.Mouse, "mousewheelmovement", Vector4.Create(dx, dx, 0, 0))
end

function love.mousepressed(x, y, button, isTouch, presses)
	local buttonString = MOUSE_INPUT_STRINGS[button]

	if buttonString then
		UserInterface.Input(Enum.InputType.Mouse, buttonString, Vector4.Create(x, y, -presses, 0))
	end
end

function love.mousereleased(x, y, button, isTouch, presses)
	local buttonString = MOUSE_INPUT_STRINGS[button]

	if buttonString then
		UserInterface.Input(Enum.InputType.Mouse, buttonString, Vector4.Create(x, y, 0, 0))
	end
end

local function ApplicationStep()
	love.event.pump()

	for name, a, b, c, d, e, f in love.event.poll() do
		if name == "quit" then
			a = a or 0

			love.quit(a)
			return a
		end

		local handler = love.handlers[name]

		if handler then
			handler(a, b, c, d, e, f)
		end
	end

	love.update(love.timer.step())

	if love.graphics.isActive() then
		love.draw()
	end

	love.timer.sleep(0.001)
end

function love.run()
	love.load(arg)

	love.timer.step()
	return ApplicationStep
end