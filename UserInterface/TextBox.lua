local Interactive = loadfile("UserInterface/Interactive.lua")(
	require("UserInterface.Label")
)

local TextBox = {}

function TextBox.Create()
	local self = Class.CreateInstance(Interactive.Create(), TextBox)

	self._PlaceholderText = "Enter text here..."
	self._PlaceholderTextColour = Vector4.Create(0.0, 0.0, 0.0, 0.5)

	self._CursorPosition = 0

	return self
end

function TextBox:Refresh()
	Interactive.Refresh(self)

	self:SetText(self:GetText())
end

function TextBox:Draw()
	Interactive.Draw(self)

	local text = self:GetText()

	local absolutePosition = self._AbsolutePosition
	
	if self._Focused then
		local absoluteCursorOffset = self:GetAbsoluteCursorOffset()
		local absoluteCursorSize = self:GetAbsoluteCursorSize()
		
		love.graphics.rectangle(
			"fill",
			absolutePosition.X + absoluteCursorOffset.X,
			absolutePosition.Y + absoluteCursorOffset.Y,
			absoluteCursorSize.X, absoluteCursorSize.Y
		)
	elseif #text == 0 then
		local absoluteTextOffset = self._AbsoluteTextOffset
		
		love.graphics.setColor(self:GetPlaceholderTextColour():Unpack())
		love.graphics.print(
			self:GetPlaceholderText(),
			absolutePosition.X + absoluteTextOffset.X,
			absolutePosition.Y + absoluteTextOffset.Y,
			0,
			1, 1
		)
	end
end

function TextBox:SetText(text)
	Interactive.SetText(self, text)

	self:SetCursorPosition(self:GetCursorPosition())
end

function TextBox:InsertText(text)
	if #text > 0 then
		local cursorPosition = self:GetCursorPosition()

		local boxText = self:GetText(self)
		local cursorByteOffset = utf8.offset(boxText, cursorPosition + 1)

		self:SetText(
			string.sub(boxText, 1, cursorByteOffset - 1)..text..string.sub(boxText, cursorByteOffset)
		)

		self:SetCursorPosition(cursorPosition + utf8.len(text))
	end
end

function TextBox:GetPlaceholderText()
	return self._PlaceholderText
end

function TextBox:SetPlaceholderText(text)
	self._PlaceholderText = tostring(text)
end

function TextBox:GetPlaceholderTextColour()
	return self._PlaceholderTextColour
end

function TextBox:SetPlaceholderTextColour(colour)
	self._PlaceholderTextColour = colour
end

function TextBox:GetCursorPosition()
	return self._CursorPosition
end

function TextBox:SetCursorPosition(position)
	self._CursorPosition = math.clamp(position, 0, utf8.len(self:GetText()))
end

function TextBox:GetAbsoluteCursorOffset()
	local cursorPosition = self._CursorPosition
	local absoluteTextOffset = self._AbsoluteTextOffset

	if cursorPosition == 0 then
		return Vector2.Create(absoluteTextOffset.X, absoluteTextOffset.Y)
	else
		local text = self:GetText()
		local textWidth = self:GetFont():GetFont(self:GetTextSize()):getWidth(
			string.sub(text, 1, utf8.offset(text, cursorPosition))
		)

		return Vector2.Create(
			textWidth + absoluteTextOffset.X, absoluteTextOffset.Y
		)
	end
end

function TextBox:GetAbsoluteCursorSize()
	return Vector2.Create(1, self:GetFont():GetFont(self:GetTextSize()):getHeight())
end

function TextBox:Submit()
	if self._AbsoluteActive then
		self._Events:Push("Submit", self:GetText())
	end
end

function TextBox:Input(inputType, scancode, state)
	if state.Z < 0 then
		if inputType == Enum.InputType.Keyboard then
			if scancode == "left" then
				self:SetCursorPosition(self:GetCursorPosition() - 1)
			elseif scancode == "right" then
				self:SetCursorPosition(self:GetCursorPosition() + 1)
			elseif scancode == "backspace" then
				local text = self:GetText()
				local cursorPosition = self:GetCursorPosition()

				if cursorPosition > 0 and #text > 0 then
					self:SetText(string.replace(
						text,
						utf8.offset(text, cursorPosition),
						utf8.offset(text, cursorPosition + 1) - 1,
						""
					))
					
					if cursorPosition < utf8.len(text) then
						self:SetCursorPosition(cursorPosition - 1)
					end
				end

			elseif scancode == "return" then
				self:Submit()
			end
		elseif inputType == Enum.InputType.Mouse then
			if scancode == "leftmousebutton" then
				local text = self:GetText()
				
				if #text == 0 then
					self:SetCursorPosition(0)
				else
					self:SetCursorPosition(math.floor((
						((state.X - self._AbsoluteTextOffset.X) / self._AbsoluteTextSize.X) * utf8.len(text)
					) + 0.5))
				end
			end
		end
	end
end

function TextBox:TextInput(text)
	if self._AbsoluteActive then
		self:InsertText(text)
	end
end

return Class.CreateClass(TextBox, "TextBox", Interactive)