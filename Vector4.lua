local Vector4 = {}

function Vector4.Create(x, y, z, w)
	local self = Class.CreateInstance(nil, Vector4)

	local xType = Class.GetType(x)
	if xType == "number" then
		self.X = x
		self.Y = y
		self.Z = z
		self.W = w
	elseif xType == "Vector2" then
		self.X = x.X
		self.Y = x.Y
		self.Z = y or 0
		self.W = z or 0
	elseif xType == "Vector3" then
		self.X = x.X
		self.Y = x.Y
		self.Z = x.Z
		self.W = y or 0
	else
		self.X = x.X
		self.Y = x.Y
		self.Z = x.Z
		self.W = x.W
	end

	return self
end

function Vector4:Lerp(otherVector, parameter)
	return self * (1 - parameter) + otherVector * parameter
end

function Vector4:Dot(otherVector)
	return
		self.X * otherVector.X +
		self.Y * otherVector.Y +
		self.Z * otherVector.Z +
		self.W * otherVector.W
end

function Vector4:SquaredMagnitude()
	return self.X^2 + self.Y^2 + self.Z^2 + self.W^2
end

function Vector4:Magnitude()
	return math.sqrt(self.X^2 + self.Y^2 + self.Z^2 + self.W^2)
end

function Vector4:Normalise()
	local magnitude = math.sqrt(self.X^2 + self.Y^2 + self.Z^2 + self.W^2)

	if magnitude == 0 then
		return Vector4.Create(0, 0, 0, 0)
	else
		return self / magnitude
	end
end

function Vector4:Unpack()
	return self.X, self.Y, self.Z, self.W
end

function Vector4.__add(leftVector, rightVector)
	local leftX, leftY, leftZ, leftW = leftVector:Unpack()
	local rightX, rightY, rightZ, rightW

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
		rightZ = rightVector
		rightW = rightVector
	else
		rightX, rightY, rightZ, rightW = rightVector:Unpack()
		rightZ = rightZ or 0
		rightW = rightW or 0
	end

	return Vector4.Create(
		leftX + rightX,
		leftY + rightY,
		leftZ + rightZ,
		leftW + rightW
	)
end

function Vector4.__sub(leftVector, rightVector)
	local leftX, leftY, leftZ, leftW = leftVector:Unpack()
	local rightX, rightY, rightZ, rightW

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
		rightZ = rightVector
		rightW = rightVector
	else
		rightX, rightY, rightZ, rightW = rightVector:Unpack()
		rightZ = rightZ or 0
		rightW = rightW or 0
	end

	return Vector4.Create(
		leftX - rightX,
		leftY - rightY,
		leftZ - rightZ,
		leftW - rightW
	)
end

function Vector4.__div(leftVector, rightVector)
	local leftX, leftY, leftZ, leftW = leftVector:Unpack()
	local rightX, rightY, rightZ, rightW

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
		rightZ = rightVector
		rightW = rightVector
	else
		rightX, rightY, rightZ, rightW = rightVector:Unpack()
		rightZ = rightZ or 1
		rightW = rightW or 1
	end

	return Vector4.Create(
		leftX / rightX,
		leftY / rightY,
		leftZ / rightZ,
		leftW / rightW
	)
end

function Vector4.__mul(leftVector, rightVector)
	local leftX, leftY, leftZ, leftW = leftVector:Unpack()
	local rightX, rightY, rightZ, rightW

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
		rightZ = rightVector
		rightW = rightVector
	else
		rightX, rightY, rightZ, rightW = rightVector:Unpack()
		rightZ = rightZ or 0
		rightW = rightW or 0
	end

	return Vector4.Create(
		leftX * rightX,
		leftY * rightY,
		leftZ * rightZ,
		leftW * rightW
	)
end

function Vector4.__unm(vector)
	local x, y, z, w = vector:Unpack()

	return Vector4.Create(-x, -y, -z, -w)
end

function Vector4.__len(vector)
	return vector:Magnitude()
end

function Vector4.__equ(leftVector, rightVector)
	local leftX, leftY, leftZ, leftW = leftVector:Unpack()
	local rightX, rightY, rightZ, rightW = rightVector:Unpack()

	return leftX == rightX and leftY == rightY and leftZ == rightZ and leftW == rightW
end

function Vector4.__tostring(vector)
	return string.format("(%.3f, %.3f, %.3f, %.3f)", vector:Unpack())
end

Class.CreateClass(Vector4, "Vector4")

Vector4.Zero = Vector4.Create(0, 0, 0, 0)
Vector4.One = Vector4.Create(1, 1, 1, 1)

return Class.CreateClass(Vector4, "Vector4")