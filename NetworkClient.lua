local NetworkController = require("NetworkController")

local NetworkClient = {}

function NetworkClient.Create(clientSocket)
	local self = Class.CreateInstance(NetworkController.Create(clientSocket), NetworkClient)

	return self
end

function NetworkClient:ConnectUsingIPAddress(IPAddress, port, timeout)
	self._Socket:settimeout(timeout)
	local success, errorMessage = self._Socket:connect(IPAddress, port)
	self._Socket:settimeout(0)

	if success == 1 then
		return true
	else
		local sourceIPAddress, sourcePort = self:GetLocalDetails()

		Log.Error(
			Enum.LogCategory.Network,
			"%s:%s failed to connect to %s:%s! %s",
			sourceIPAddress, sourcePort,
			ipAddress, port,
			errorMessage
		)

		return false
	end
end

function NetworkClient:ConnectUsingMACAddress(macAddress)

end

function NetworkClient:GetLocalDetails()
	return self._Socket:getsockname()
end

function NetworkClient:GetRemoteDetails()
	return self._Socket:getpeername()
end

function NetworkClient:Update()
	NetworkController.Update(self)

	local commands
	local data = buffer.new()
	local retries = 0
	local errorMessage = "Retry limit reached"

	while retries <= self._Retries do
		local partialData, partialErrorMessage = self._Socket:receive("*l")
			
		if partialData then
			data:put(partialData)

			commands = NetworkController.GetCommandsFromString(data:tostring())

			if commands then
				break
			end
		else
			errorMessage = partialErrorMessage

			break
		end

		retries = retries + 1
	end

	if #data > 0 then
		if commands then
			for _, command in ipairs(commands) do
				self._Events:Push(command[0], unpack(command))
			end
		else
			local sourceIPAddress, sourcePort = self:GetLocalDetails()
			local remoteIPAddress, remotePort = self:GetRemoteDetails()

			Log.Error(
				Enum.LogCategory.Network,
				"%s:%s failed to read valid data from %s:%s! %s",
				sourceIPAddress, sourcePort,
				remoteIPAddress, remotePort,
				errorMessage
			)
		end
	end

	data:free()
end

function NetworkClient:Send(commands)
	local commandsString = NetworkController.GetStringFromCommands(commands).."\n"

	local lastByteSent = 1
	local errorMessage

	while lastByteSent < #commandsString do
		lastByteSent, errorMessage = self._Socket:send(commandsString, lastByteSent + 1)

		if not lastByteSent then
			local sourceIPAddress, sourcePort = self:GetLocalDetails()
			local remoteIPAddress, remotePort = self:GetRemoteDetails()

			Log.Error(
				Enum.LogCategory.Network,
				"%s:%s failed to send data to %s:%s! %s",
				sourceIPAddress, sourcePort,
				remoteIPAddress, remotePort,
				errorMessage
			)

			return false
		end
	end

	return true
end

return Class.CreateClass(NetworkClient, "NetworkClient", NetworkController)