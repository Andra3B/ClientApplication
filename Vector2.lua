local Vector2 = {}

function Vector2.Create(x, y)
	local self = Class.CreateInstance(nil, Vector2)

	if type(x) == "number" then
		self.X = x
		self.Y = y
	else
		self.X = x.X
		self.Y = x.Y
	end

	return self
end

function Vector2:Lerp(otherVector, parameter)
	return self * (1 - parameter) + otherVector * parameter
end

function Vector2:Dot(otherVector)
	return
		self.X * otherVector.X +
		self.Y * otherVector.Y
end

function Vector2:SquaredMagnitude()
	return self.X^2 + self.Y^2
end

function Vector2:Magnitude()
	return math.sqrt(self.X^2 + self.Y^2)
end

function Vector2:Normalise()
	local magnitude = math.sqrt(self.X^2 + self.Y^2)

	if magnitude == 0 then
		return Vector2.Create(0, 0)
	else
		return self / magnitude
	end
end

function Vector2:Unpack()
	return self.X, self.Y
end

function Vector2.__add(leftVector, rightVector)
	local leftX, leftY = leftVector:Unpack()
	local rightX, rightY

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
	else
		rightX, rightY = rightVector:Unpack()
	end

	return Vector2.Create(
		leftX + rightX,
		leftY + rightY
	)
end

function Vector2.__sub(leftVector, rightVector)
	local leftX, leftY = leftVector:Unpack()
	local rightX, rightY

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
	else
		rightX, rightY = rightVector:Unpack()
	end

	return Vector2.Create(
		leftX - rightX,
		leftY - rightY
	)
end

function Vector2.__mul(leftVector, rightVector)
	local leftX, leftY = leftVector:Unpack()
	local rightX, rightY

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
	else
		rightX, rightY = rightVector:Unpack()
	end

	return Vector2.Create(
		leftX * rightX,
		leftY * rightY
	)
end

function Vector2.__div(leftVector, rightVector)
	local leftX, leftY = leftVector:Unpack()
	local rightX, rightY

	if type(rightVector) == "number" then
		rightX = rightVector
		rightY = rightVector
	else
		rightX, rightY = rightVector:Unpack()
	end

	return Vector2.Create(
		leftX / rightX,
		leftY / rightY
	)
end

function Vector2.__unm(vector)
	local x, y = vector:Unpack()

	return Vector2.Create(-x, -y)
end

function Vector2.__len(vector)
	return vector:Magnitude()
end

function Vector2.__equ(leftVector, rightVector)
	local leftX, leftY = leftVector:Unpack()
	local rightX, rightY = rightVector:Unpack()

	return leftX == rightX and leftY == rightY
end

function Vector2.__tostring(vector)
	return string.format("(%.3f, %.3f)", vector:Unpack())
end

Class.CreateClass(Vector2, "Vector2")

Vector2.Zero = Vector2.Create(0, 0)
Vector2.One = Vector2.Create(1, 1)

Vector2.Up = Vector2.Create(0, 1)
Vector2.Down = Vector2.Create(0, -1)
Vector2.Right = Vector2.Create(1, 0)
Vector2.Left = Vector2.Create(-1, 0)

return Vector2