local BASE_CLASS = ...
if not BASE_CLASS then error("Failed to create interative widget! BASE_CLASS not defined.", 2) end

local Interactive = {}

function Interactive.Create()
	local self = Class.CreateInstance(BASE_CLASS.Create(), Interactive)
	
	self._Active = true
	self._AbsoluteActive = true
	
	self._Focused = false
	self._Hovering = false
	
	self._InactiveBackgroundColour = nil
	self._InactiveColourMultiplier = 0.75
	
	self._FocusedBackgroundColour = nil
	self._FocusedColourMultiplier = 1.5
	
	self._HoveringBackgroundColour = nil
	self._HoveringColourMultiplier = 1.5

	return self
end

function Interactive:Refresh()
	BASE_CLASS.Refresh(self)

	local interactiveAncestor = self:GetAncestorWithType("Interactive")

	if interactiveAncestor then
		self._AbsoluteActive = interactiveAncestor._AbsoluteActive and self._Active
	else
		self._AbsoluteActive = self._Active
	end
end

function Interactive:GetBackgroundColour()
	local backgroundColour = BASE_CLASS.GetBackgroundColour(self)

	if not self._AbsoluteActive then
		return
			self:GetInactiveBackgroundColour() or
			backgroundColour * self:GetInactiveColourMultiplier()
	elseif self._Hovering then
		return
			self:GetHoveringBackgroundColour() or
			backgroundColour * self:GetHoveringColourMultiplier()
	elseif self._Focused then
		return
			self:GetFocusedBackgroundColour() or
			backgroundColour * self:GetFocusedColourMultiplier()
	else
		return backgroundColour
	end
end

function Interactive:IsActive()
	return self._Active
end

function Interactive:GetInactiveBackgroundColour()
	return self._InactiveBackgroundColour
end

function Interactive:GetInactiveColourMultiplier()
	return self._InactiveColourMultiplier
end

function Interactive:SetActive(active)
	self._Active = active
end

function Interactive:SetInactiveBackgroundColour(colour)
	self._InactiveBackgroundColour = colour
end

function Interactive:SetInactiveColourMultiplier(multiplier)
	self._InactiveColourMultiplier = multiplier
end

function Interactive:IsFocused()
	return self._Focused
end

function Interactive:GetFocusedBackgroundColour()
	return self._FocusedBackgroundColour
end

function Interactive:GetFocusedColourMultiplier()
	return self._FocusedColourMultiplier
end

function Interactive:SetFocused(focus)
	self._Focused = focus
end

function Interactive:SetFocusedBackgroundColour(colour)
	self._FocusedBackgroundColour = colour
end

function Interactive:SetFocusedColourMultiplier(multiplier)
	self._FocusedColourMultiplier = multiplier
end

function Interactive:IsHovering()
	return self._Hovering
end

function Interactive:GetHoveringBackgroundColour()
	return self._HoveringBackgroundColour
end

function Interactive:GetHoveringColourMultiplier()
	return self._HoveringColourMultiplier
end

function Interactive:SetHovering(hovering)
	self._Hovering = hovering
end

function Interactive:SetHoveringBackgroundColour(colour)
	self._HoveringBackgroundColour = colour
end

function Interactive:SetHoveringColourMultiplier(multiplier)
	self._HoveringColourMultiplier = multiplier
end

function Interactive:Destroy()
	if not self._Destroyed then
		self._InactiveBackgroundColour = nil
		self._FocusedBackgroundColour = nil
		self._HoveringBackgroundColour = nil
		
		BASE_CLASS.Destroy(self)
	end
end

return Class.CreateClass(Interactive, "Interactive", BASE_CLASS)