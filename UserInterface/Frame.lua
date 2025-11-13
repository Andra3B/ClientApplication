local Hierarchy = require("UserInterface.Hierarchy")

local Frame = {}

function Frame.Create()
	local self = Class.CreateInstance(Hierarchy.Create(), Frame)

	self._RelativePosition = Vector2.Zero
	self._PixelPosition = Vector2.Zero
	self._AbsolutePosition = Vector2.Zero

	self._RelativeSize = Vector2.Zero
	self._PixelSize = Vector2.Zero
	self._AbsoluteSize = Vector2.Zero

	self._BackgroundColour = Vector4.One
	self._BackgroundImage = nil

	self._CornerRadius = 0

	return self
end

function Frame:Draw()
	local absolutePosition = self._AbsolutePosition
	local absoluteSize = self._AbsoluteSize
	local backgroundImage = self:GetBackgroundImage()
	local cornerRadius = self:GetCornerRadius()

	love.graphics.setColor(self:GetBackgroundColour():Unpack())
	love.graphics.rectangle(
		"fill",
		absolutePosition.X, absolutePosition.Y,
		absoluteSize.X, absoluteSize.Y,
		cornerRadius, cornerRadius
	)

	if backgroundImage then
		local width, height = backgroundImage:getDimensions()
		
		love.graphics.draw(
			backgroundImage,
			absolutePosition.X, absolutePosition.Y,
			0,
			absoluteSize.X / width, absoluteSize.Y / height,
			0, 0,
			0, 0
		)
	end
end

function Frame:RecursiveDraw()
	self:Draw()

	for _, child in ipairs(self._Children) do
		if Class.IsA(child, "Frame") then
			child:RecursiveDraw()
		end
	end
end

function Frame:Refresh()
	Hierarchy.Refresh(self)

	local parentAbsolutePosition
	local parentAbsoluteSize
	local parent = self._Parent

	if parent then
		parentAbsolutePosition = parent._AbsolutePosition
		parentAbsoluteSize = parent._AbsoluteSize
	else
		parentAbsolutePosition = Vector2.Zero
		parentAbsoluteSize = Vector2.Create(love.graphics.getDimensions())
	end

	self._AbsolutePosition = parentAbsoluteSize * self._RelativePosition + parentAbsolutePosition + self._PixelPosition
	self._AbsoluteSize = parentAbsoluteSize * self._RelativeSize + self._PixelSize
end

function Frame:GetRelativePosition()
	return self._RelativePosition
end

function Frame:SetRelativePosition(position)
	if self._RelativePosition ~= position then
		self._RelativePosition = position

		self:RecursiveRefresh()
	end
end

function Frame:GetPixelPosition()
	return self._PixelPosition
end

function Frame:SetPixelPosition(position)
	if self._PixelPosition ~= position then
		self._PixelPosition = position

		self:RecursiveRefresh()
	end
end

function Frame:GetAbsolutePosition()
	return self._AbsolutePosition
end

function Frame:GetRelativeSize()
	return self._RelativeSize
end

function Frame:SetRelativeSize(size)
	if self._RelativeSize ~= size then
		self._RelativeSize = size

		self:RecursiveRefresh()
	end
end

function Frame:GetPixelSize()
	return self._PixelSize
end

function Frame:SetPixelSize(size)
	if self._PixelSize ~= size then
		self._PixelSize = size

		self:RecursiveRefresh()
	end
end

function Frame:GetAbsoluteSize()
	return self._AbsoluteSize
end

function Frame:GetBackgroundColour()
	return self._BackgroundColour
end

function Frame:SetBackgroundColour(colour)
	self._BackgroundColour = colour
end

function Frame:GetBackgroundImage()
	return self._BackgroundImage
end

function Frame:SetBackgroundImage(image)
	self._BackgroundImage = image
end

function Frame:GetCornerRadius()
	return self._CornerRadius
end

function Frame:SetCornerRadius(radius)
	self._CornerRadius = radius
end

function Frame:Destroy()
	if not self._Destroyed then
		self._RelativePosition = nil
		self._PixelPosition = nil

		self._RelativeSize = nil
		self._PixelSize = nil

		self._AbsolutePosition = nil
		self._AbsoluteSize = nil

		self._BackgroundColour = nil

		Hierarchy.Destroy(self)
	end
end

return Class.CreateClass(Frame, "Frame", Hierarchy)