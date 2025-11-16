local Frame = require("UserInterface.Frame")

local VideoFrame = {}

function VideoFrame.Create()
	local self = Class.CreateInstance(Frame.Create(), VideoFrame)

	self._Video = nil

	self._Playing = false
	self._Timer = 0

	return self
end

function VideoFrame:Update(deltaTime)
	Frame.Update(self, deltaTime)

	local video = self:GetVideo()

	if video and self:IsPlaying() and not video:IsEndOfStream() then
		self._Timer = self._Timer - deltaTime

		if self._Timer <= 0 then
			local lastFrameTime = video:GetTime()

			video:GetNextFrame()
			video:RefreshYUVImages()
			self._Timer = video:GetTime() - lastFrameTime
		end
	end
end

function VideoFrame:Draw()
	local video = self:GetVideo()

	if video then
		video:RefreshRGBAImage()

		local absolutePosition = self:GetAbsolutePosition()
		local absoluteSize = self:GetAbsoluteSize()
		
		local rgbaImage = video:GetRGBAImage()
		local width, height = rgbaImage:getDimensions()

		love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
		love.graphics.draw(
			rgbaImage,
			absolutePosition.X, absolutePosition.Y,
			0,
			absoluteSize.X / width, absoluteSize.Y / height,
			0, 0,
			0, 0
		)
	else
		Frame.Draw(self)
	end
end

function VideoFrame:GetVideo()
	return self._Video
end

function VideoFrame:SetVideo(video)
	if Class.IsA(video, "Video") then
		self._Video = video
		self._Timer = 0

		return true
	end

	return false
end

function VideoFrame:IsPlaying()
	return self._Playing
end

function VideoFrame:SetPlaying(playing)
	self._Playing = playing
end

function VideoFrame:Destroy()
	if not self._Destroyed then
		if self._Video then
			self._Video:Destroy()
		end

		self._Video = nil

		Frame.Destroy(self)
	end
end

return Class.CreateClass(VideoFrame, "VideoFrame", Frame)