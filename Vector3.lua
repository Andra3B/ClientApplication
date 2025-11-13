local Vector3 = {}

function Vector3.Create(x, y, z)
	local self = Class.CreateInstance(nil, Vector3)

	local xType = Class.GetType(x)
	if xType == "number" then
		self.X = x
		self.Y = y
		self.Z = z
	elseif xType == "Vector2" then
		self.X = x.X
		self.Y = x.Y
		self.Z = y or 0
	else
		self.X = x.X
		self.Y = x.Y
		self.Z = x.Z
	end

	return self
end

function Vector3:Lerp(otherVector, parameter)
	return self * (1 - parameter) + otherVector * parameter
end

function Vector3:Dot(otherVector)
	return
		self.X * otherVector.X +
		self.Y * otherVector.Y +
		self.Z * otherVector.Z
end

function Vector3:Cross(otherVector)
	local selfX, selfY, selfZ = self.X, self.Y, self.Z
	local x, y, z = otherVector.X, otherVector.Y, otherVector.Z

	return Vector3.Create(
		selfY*z - selfZ*y,
		selfZ*x - selfX*z,
		selfX*y - selfY*x
	)
end

function Vector3:SquaredMagnitude()
	return self.X^2 + self.Y^2 + self.Z^2
end

function Vector3:Magnitude()
	return math.sqrt(self.X^2 + self.Y^2 + self.Z^2)
end

function Vector3:Normalise()
	local magnitude = math.sqrt(self.X^2 + self.Y^2 + self.Z^2)

	if magnitude == 0 then
		return Vector3.Create(0, 0, 0)
	else
		return self / magnitude
	end
end

function Vector3:Unpack()
	return self.X, self.Y, self.Z
end

function Vector3.__add(leftVector, rightVector)
	local leftX, leftY, leftZ = leftVector:Unpack()
	local rightX, rightY, rightZ

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
		rightZ = rightVector
	else
		rightX, rightY, rightZ = rightVector:Unpack()
		rightZ = rightZ or 0
	end

	return Vector3.Create(
		leftX + rightX,
		leftY + rightY,
		leftZ + rightZ
	)
end

function Vector3.__sub(leftVector, rightVector)
	local leftX, leftY, leftZ = leftVector:Unpack()
	local rightX, rightY, rightZ

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
		rightZ = rightVector
	else
		rightX, rightY, rightZ = rightVector:Unpack()
		rightZ = rightZ or 0
	end

	return Vector3.Create(
		leftX - rightX,
		leftY - rightY,
		leftZ - rightZ
	)
end

function Vector3.__mul(leftVector, rightVector)
	local leftX, leftY, leftZ = leftVector:Unpack()
	local rightX, rightY, rightZ

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
		rightZ = rightVector
	else
		rightX, rightY, rightZ = rightVector:Unpack()
		rightZ = rightZ or 0
	end

	return Vector3.Create(
		leftX * rightX,
		leftY * rightY,
		leftZ * rightZ
	)
end

function Vector3.__div(leftVector, rightVector)
	local leftX, leftY, leftZ = leftVector:Unpack()
	local rightX, rightY, rightZ

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
		rightZ = rightVector
	else
		rightX, rightY, rightZ = rightVector:Unpack()
		rightZ = rightZ or 1
	end

	return Vector3.Create(
		leftX / rightX,
		leftY / rightY,
		leftZ / rightZ
	)
end

function Vector3.__unm(vector)
	local x, y, z = vector:Unpack()

	return Vector3.Create(-x, -y, -z)
end

function Vector3.__len(vector)
	return vector:Magnitude()
end

function Vector3.__equ(leftVector, rightVector)
	local leftX, leftY, leftZ = leftVector:Unpack()
	local rightX, rightY, rightZ = rightVector:Unpack()

	return leftX == rightX and leftY == rightY and leftZ == rightZ
end

function Vector3.__tostring(vector)
	return string.format("(%.3f, %.3f, %.3f)", vector:Unpack())
end

Class.CreateClass(Vector3, "Vector3")

Vector3.Zero = Vector3.Create(0, 0, 0)
Vector3.One = Vector3.Create(1, 1, 1)

Vector3.Up = Vector3.Create(0, 1, 0)
Vector3.Down = Vector3.Create(0, -1, 0)
Vector3.Right = Vector3.Create(1, 0, 0)
Vector3.Left = Vector3.Create(-1, 0, 0)
Vector3.Forward = Vector3.Create(0, 0, 1)
Vector3.Backward = Vector3.Create(0, 0, -1)

return Class.CreateClass(Vector3, "Vector3")