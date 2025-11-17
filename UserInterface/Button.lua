local Interactive = loadfile("UserInterface/Interactive.lua")(
	require("UserInterface.Label")
)

local Button = {}

function Button.Create()
	local self = Class.CreateInstance(Interactive.Create(), Button)

	self._Pressed = false 

	self._PressedBackgroundColour = nil
	self._PressedColourMultiplier = 2

	return self
end

function Button:Input(inputType, scancode, state)
	if inputType == Enum.InputType.Mouse and scancode == "leftmousebutton" then
		self._Pressed = state.Z < 0

		if self._AbsoluteActive then
			self._Events:Push("Pressed", self._Pressed)
		end
	end
end

function Button:GetBackgroundColour()
	if self._AbsoluteActive and self._Pressed then
		return
			self._PressedBackgroundColour or
			self._BackgroundColour * self._PressedColourMultiplier
	else
		return Interactive.GetBackgroundColour(self)
	end
end

function Button:IsPressed()
	return self._Pressed
end

function Button:GetPressedBackgroundColour()
	return self._PressedBackgroundColour
end

function Button:GetPressedColourMultiplier()
	return self._PressedColourMultiplier
end

return Class.CreateClass(Button, "Button", Interactive)