local Class = {}

Class.__index = Class
Class.Type = "Class"

local function IndexMetamethod(self, name)
	local getter = self.Class["Get"..name] or self.Class["Is"..name]

	if getter then
		return getter(self)
	else
		return self.Class[name]
	end
end

local function NewIndexMetamethod(self, name, value)
	local setter = self.Class["Set"..name]

	if setter then
		return setter(self, value)
	else
		rawset(self, name, value)
	end
end

function Class.CreateClass(class, typeName, base)
	base = base or Class
	
	for name, value in pairs(base) do
		if string.sub(name, 1, 2) == "__" and not class[name] then
			class[name] = value
		end
	end

	class.Type = typeName
	class.__index = class
	
	class.InstanceMetatable = {}
	class.CLASS_INDICATOR = true

	for name, value in pairs(class) do
		if string.sub(name, 1, 2) == "__" then
			class.InstanceMetatable[name] = value
		end
	end

	class.InstanceMetatable.__index = IndexMetamethod
	class.InstanceMetatable.__newindex = NewIndexMetamethod
	
	return setmetatable(class, base)
end

function Class.CreateInstance(instance, class)
	if instance then
		instance.Class = class
	else
		instance = {Class = class, CLASS_INSTANCE_INDICATOR = true}
	end

	return setmetatable(instance, class.InstanceMetatable)
end

function Class:IsA(typeName)
	if type(self) == "table" and self.CLASS_INSTANCE_INDICATOR then
		for class in self:IterateInheritance() do
			if class.Type == typeName then
				return true
			end
		end
	end
	
	return false
end

function Class:GetType()
	local luaType = type(self)

	if luaType == "table" and self.CLASS_INDICATOR then
		return self.Type
	end

	return luaType
end

local function InheritanceIterator(stopAt, currentClass)
	if currentClass.CLASS_INSTANCE_INDICATOR then
		return currentClass.Class
	else
		local nextClass = getmetatable(currentClass)

		if nextClass ~= stopAt then
			return nextClass
		end
	end
end

function Class:IterateInheritance(stopAt)
	return InheritanceIterator, stopAt, self
end

function Class.__tostring(object)
	if object.CLASS_INSTANCE_INDICATOR then
		return object.Class.Type.." Instance"
	else
		return object.Type.." Class"
	end
end

return Class