local Font = {}

function Font.Create(fontPath)
	if love.filesystem.getInfo(fontPath, "file") and string.match(fontPath, ".*%.ttf$") then
		local self = Class.CreateInstance(nil, Font)

		self._FontPath = fontPath
		self._Fonts = {}

		self._Destroyed = false

		return self
	end
end

function Font:GetFontPath()
	return self._FontPath
end

function Font:GetFont(size, sizeTolerance)
	sizeTolerance = sizeTolerance or 5

	if self._Fonts[size] then
		return self._Fonts[size]
	else
		local closest
		local closestSizeDifference = sizeTolerance

		for fontSize, font in pairs(self._Fonts) do
			local sizeDifference = math.abs(size - fontSize)

			if sizeDifference < closestSizeDifference then
				closest = font
				closestSizeDifference = sizeDifference
			end
		end

		if not closest then
			closest = love.graphics.newFont(self._FontPath, size)
			self._Fonts[size] = closest
		end

		return closest
	end
end

function Font:RemoveAllFonts()
	for size, font in pairs(self._Fonts) do
		self._Fonts[size] = nil
		font:release()
	end
end

function Font:IterateFonts()
	return pairs(self._Fonts)
end

function Font:Destroy()
	if not self._Destroyed then
		self:RemoveAllFonts()

		self._Destroyed = true
	end
end

Class.CreateClass(Font, "Font")

Font.FreeSans = Font.Create("Assets/Fonts/FreeSans/FreeSans.ttf")

Font.Default = Font.FreeSans

return Font