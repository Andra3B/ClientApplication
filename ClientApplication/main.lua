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

local ApplicationNetworkClient = nil

local ConnectionInputIPAddressTextBox = nil
local ConnectionInputPortTextBox = nil
local ConnectionInputButton = nil

local LivestreamVideoFrame = nil
local LivestreamButton = nil

local StatusLabel = nil

local function OnConnectionInputButtonClicked(pressed)
	if pressed then
		local ipAddress = ConnectionInputIPAddressTextBox.Text
		local port = ConnectionInputPortTextBox.Text

		local success, errorMessage = ApplicationNetworkClient:ConnectUsingIPAddress(
			ipAddress, port,
			3
		)

		if success then
			StatusLabel.Text = string.format(
				"Connection Details: %s:%s",
				ApplicationNetworkClient:GetRemoteDetails()
			)
		else
			StatusLabel.Text = string.format("Failed to connect to %s:%s! %s",
				ipAddress,
				port,
				errorMessage
			)
		end
	end
end

local function OnStopLivestream()
	LivestreamVideoFrame.Video:Destroy()
	LivestreamVideoFrame.Video = nil

	LivestreamButton.Text = "Start Livestream"
end

local function OnLivestreamButtonClicked(pressed)
	if pressed and ApplicationNetworkClient:GetRemoteDetails() then
		if LivestreamVideoFrame.Video then
			LivestreamVideoFrame.Video:Destroy()
			LivestreamVideoFrame.Video = nil
			
			LivestreamButton.Text = "Start Livestream"

			ApplicationNetworkClient:Send({{
				"StopLivestream"
			}})
		else
			ApplicationNetworkClient:Send({{
				"StartLivestream",
				5001
			}})

			LivestreamVideoFrame.Video = UserInterface.Video.CreateFromURL("udp://192.168.1.204:5001?timeout=1000000")
			LivestreamVideoFrame.Playing = true

			LivestreamButton.Text = "Stop Livestream"
		end
	end
end

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

	ApplicationNetworkClient = NetworkClient.Create()

	ApplicationNetworkClient.Events:Listen("StopLivestream", OnStopLivestream)

	ApplicationNetworkClient:Bind("192.168.1.204", 0)

	local Root = UserInterface.Frame.Create()
	Root.RelativeSize = Vector2.Create(1, 1)
	Root.BackgroundColour = Vector4.Create(1, 1, 1, 1)

	ConnectionInput = UserInterface.Frame.Create()
	ConnectionInput.RelativeSize = Vector2.Create(0.95, 0.2)
	ConnectionInput.RelativePosition = Vector2.Create(0.025, 0.025)
	ConnectionInput.BackgroundColour = Vector4.Zero

	ConnectionInputIPAddressTextBox = UserInterface.TextBox.Create()
	ConnectionInputIPAddressTextBox.RelativeSize = Vector2.Create(0.5, 0.5)
	ConnectionInputIPAddressTextBox.BackgroundColour = Vector4.Create(0, 0, 0, 0.1)
	ConnectionInputIPAddressTextBox.PlaceholderText = "Enter IP Address..."

	ConnectionInputPortTextBox = UserInterface.TextBox.Create()
	ConnectionInputPortTextBox.RelativeSize = Vector2.Create(0.5, 0.5)
	ConnectionInputPortTextBox.RelativePosition = Vector2.Create(0.5, 0)
	ConnectionInputPortTextBox.BackgroundColour = Vector4.Create(0, 0, 0, 0.1)
	ConnectionInputPortTextBox.PlaceholderText = "Enter Port..."

	ConnectionInputButton = UserInterface.Button.Create()
	ConnectionInputButton.RelativeSize = Vector2.Create(1, 0.5)
	ConnectionInputButton.RelativePosition = Vector2.Create(0, 0.5)
	ConnectionInputButton.BackgroundColour = Vector4.Create(0, 0, 0, 0.1)
	ConnectionInputButton.TextHorizontalAlignment = Enum.HorizontalAlignment.Middle
	ConnectionInputButton.Text = "Connect"

	ConnectionInputButton.Events:Listen("Pressed", OnConnectionInputButtonClicked)

	LivestreamVideoFrame = UserInterface.VideoFrame.Create()
	LivestreamVideoFrame.RelativeSize = Vector2.Create(0.95, 0.575)
	LivestreamVideoFrame.RelativePosition = Vector2.Create(0.025, 0.25)
	LivestreamVideoFrame.BackgroundColour = Vector4.Create(0, 0, 0, 0.1)

	LivestreamButton = UserInterface.Button.Create()
	LivestreamButton.RelativeSize = Vector2.Create(0.95, 0.05)
	LivestreamButton.RelativePosition = Vector2.Create(0.025, 0.825)
	LivestreamButton.BackgroundColour = Vector4.Create(0, 0, 0, 0.1)
	LivestreamButton.TextHorizontalAlignment = Enum.HorizontalAlignment.Middle
	LivestreamButton.Text = "Start Livestream"

	LivestreamButton.Events:Listen("Pressed", OnLivestreamButtonClicked)

	StatusLabel = UserInterface.Label.Create()
	StatusLabel.RelativeSize = Vector2.Create(0.95, 0.075)
	StatusLabel.RelativePosition = Vector2.Create(0.025, 0.9)
	StatusLabel.BackgroundColour = Vector4.Create(0, 0, 0, 0.1)
	StatusLabel.Text = string.format(
		"Application Address: %s:%s",
		ApplicationNetworkClient:GetLocalDetails()
	)

	ConnectionInput:AddChild(ConnectionInputIPAddressTextBox)
	ConnectionInput:AddChild(ConnectionInputPortTextBox)
	ConnectionInput:AddChild(ConnectionInputButton)

	Root:AddChild(ConnectionInput)
	Root:AddChild(LivestreamVideoFrame)
	Root:AddChild(LivestreamButton)
	Root:AddChild(StatusLabel)

	UserInterface.SetRoot(Root)
end

function love.quit(exitCode)
	UserInterface.Deinitialise()
	
	ApplicationNetworkClient:Destroy()
	ApplicationNetworkClient = nil
end

function love.update(deltaTime)
	ApplicationNetworkClient:Update()

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
	UserInterface.Input(Enum.InputType.Mouse, button, Vector4.Create(x, y, -presses, 0))
end

function love.mousereleased(x, y, button, isTouch, presses)
	UserInterface.Input(Enum.InputType.Mouse, button, Vector4.Create(x, y, 0, 0))
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