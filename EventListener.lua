local EventListener = {}

function EventListener.Create(callback, userData, userDataCleanup)
	local self = Class.CreateInstance(nil, EventListener)

	self._Callback = callback
    
    self._UserData = userData
    self._UserDataCleanup = userDataCleanup

    self._Destroyed = false

	return self
end

function EventListener:Trigger(...)
	local destroy

	if self._UserData == nil then
		destroy = self._Callback(...)
	else
		destroy = self._Callback(self._UserData, ...)
	end

    if destroy then
        self:Destroy()

        return true
    end
	
	return false
end

function EventListener:IsDestroyed()
	return self._Destroyed
end

function EventListener:Destroy()
    if not self._Destroyed then
        self._Callback = nil

        if self._UserDataCleanup then
            self._UserDataCleanup(self._UserData)
        end

        self._UserData = nil
        self._UserDataCleanup = nil

        self._Destroyed = true
    end
end

return Class.CreateClass(EventListener, "EventListener")