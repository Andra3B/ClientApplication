local NetworkController = {}

function NetworkController.Create(controllerSocket)
	local self = Class.CreateInstance(nil, NetworkController)

	self._Socket = controllerSocket or socket.tcp()
	self._Socket:settimeout(0)
	
	self._Retries = 3

	self._Events = EventDirector.Create()

	self._Destroyed = false

	return self
end

function NetworkController.GetStringFromCommands(commands)
	local commandsString = buffer.new():put(" ")

	for _, command in ipairs(commands) do
		commandsString:put("&", command[0])

		if #command > 0 then
			commandsString:put(":")

			for argumentIndex, argument in ipairs(command) do
				local argumentString = tostring(argument)

				if type(argument) == "string" then
					for bytePosition, codePoint in utf8.codes(argumentString) do
						local character = utf8.char(codePoint)
						
						if
							character == ',' or
							character == '!' or
							character == '&' or
							character == ':'
						then
							commandsString:put("\\")
						end

						commandsString:put(character)
					end
				end

				commandsString:put(argumentIndex < #command and "," or "")
			end
		end
	end

	local resultingString = commandsString:put("!"):get()
	commandsString:free()

	return resultingString
end

function NetworkController.GetCommandsFromString(commandsString)
	local parsedCommands = {}

	if string.sub(commandsString, -1) == "!" then
		local commandStart = nil
		
		local ignoreNext = false
		
		local commandTable = nil
		local argumentBuffer = buffer.new()

		for bytePosition, codePoint in utf8.codes(commandsString) do
			local character = utf8.char(codePoint)

			if ignoreNext then
				ignoreNext = false
			elseif character == '&' then
				if commandTable then
					table.insert(commandTable, argumentBuffer:skip(1):get())
				elseif commandStart then
					local commandName = string.sub(commandsString, commandStart + 1, bytePosition - 1)
				
					if #commandName > 0 then
						table.insert(parsedCommands, {[0] = commandName})
					end
				end

				commandStart = bytePosition
			elseif character == ':' then
				local commandName = string.sub(commandsString, commandStart + 1, bytePosition - 1)

				if #commandName > 0 then
					commandTable = {[0] = commandName}
					table.insert(parsedCommands, commandTable)
				end

				commandStart = nil
				argumentBuffer:reset()
			elseif character == ',' then
				if commandTable then
					table.insert(commandTable, argumentBuffer:skip(1):get())
				end
			elseif character == '!' then
				if commandStart then
					local commandName = string.sub(commandsString, commandStart + 1, bytePosition - 1)

					if #commandName > 0 then
						table.insert(parsedCommands, {[0] = commandName})
					end
				end

				if commandTable then
					table.insert(commandTable, argumentBuffer:skip(1):get())
				end

				break
			elseif character == '\\' then
				ignoreNext = true
			end

			if not ignoreNext then
				argumentBuffer:put(character)
			end
		end

		argumentBuffer:free()
		return parsedCommands
	end
end

function NetworkController:GetRetries()
	return self._Retries
end

function NetworkController:SetRetries(retries)
	self._Retries = retries
end

function NetworkController:Update()
	self._Events:Update()
end

function NetworkController:Destroy()
	if not self._Destroyed then
		self._Socket:close()
		self._Socket = nil

		self._Events:Destroy()
		self._Events = nil

		self._Destroyed = true
	end
end

return Class.CreateClass(NetworkController, "NetworkController")