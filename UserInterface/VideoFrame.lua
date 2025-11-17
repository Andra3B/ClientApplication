local Frame = require("UserInterface.Frame")

local VideoFrame = {}

function VideoFrame.Create()
	local self = Class.CreateInstance(Frame.Create(), VideoFrame)

	self._Video = nil

	self._Playing = false
	self._Time = 0

	return self
end

function VideoFrame:Update(deltaTime)
	Frame.Update(self, deltaTime)

	if self._Playing then
		local video = self:GetVideo()

		if video then
			self._Time = self._Time + deltaTime

			if video.FrameTime - self._Time < 0 then
				local success, needsAnotherPacket, endOfFrames

				while true do
					success = video:GetNextPacket()

					if not success or video.EndOfStream then
						self:SetPlaying(false)

						break
					else
						success, needsAnotherPacket, endOfFrames = video:GetNextFrame()
						
						if success and not needsAnotherPacket then
							break
						end
					end
				end

				video:RefreshYUVImages()
			end
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
	self._Video = video
	self._Time = 0
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