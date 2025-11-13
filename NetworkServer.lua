local NetworkController = require("NetworkController")
local NetworkClient = require("NetworkClient")

local NetworkServer = {}

function NetworkServer.Create(serverSocket)
	local self = Class.CreateInstance(NetworkController.Create(serverSocket), NetworkServer)

	self._Connections = {}
	
	return self
end

function NetworkServer:GetNetworkClient(index)
	return self._Connections[index]
end

function NetworkServer:Bind(IPAddress, port)
	local success, errorMessage = self._Socket:bind(IPAddress, port)

	if success == 1 then
		return true
	else
		Log.Error(
			Enum.LogCategory.Network,
			"Failed to bind to %s:%s! %s",
			IPAddress, port,
			errorMessage
		)

		return false
	end
end

function NetworkServer:GetLocalDetails()
	return self._Socket:getsockname()
end

function NetworkServer:Listen()
	local success, errorMessage = self._Socket:listen(10)

	if success == 1 then
		return true
	else
		local localIPAddress, localPort = self:GetLocalDetails()

		Log.Error(
			Enum.LogCategory.Network,
			"Failed to listen on %s:%s! %s",
			localIPAddress, localPort,
			errorMessage
		)

		return false
	end
end

function NetworkServer:Update()
	NetworkController.Update(self)

	while true do
		local clientSocket = self._Socket:accept()

		if clientSocket then
			local networkClient = NetworkClient.Create(clientSocket)

			table.insert(self._Connections, networkClient)
		else
			break
		end
	end

	local index = 1

	while index <= #self._Connections do
		local networkClient = self._Connections[index]

		if networkClient:GetRemoteDetails() then
			networkClient:Update()

			index = index + 1
		else
			table.remove(self._Connections, index):Destroy()
		end
	end
end

function NetworkServer:Destroy()
	if not self._Destroyed then
		for index, networkClient in pairs(self._Connections) do
			networkClient:Destroy()
			self._Connections[index] = nil
		end

		self._Connections = nil

		NetworkController.Destroy(self)
	end
end

return Class.CreateClass(NetworkServer, "NetworkServer", NetworkController)