local mathutils = {}


mathutils.Vector3 = {}

function mathutils.Vector3:new(x, y, z)
    local o = {}
    o.x = x 
    o.y = y 
    o.z = z

    setmetatable(o, self)
    self.__index = self
    return o
end

function mathutils.Vector3:add(other)
    local retval = mathutils.Vector3:new(self.x, self.y, self.z)
    retval:addSelf(other)
    return retval
end

function mathutils.Vector3:addSelf(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    self.z = self.z + other.z
end

function mathutils.Vector3:multSelf(factor)
    self.x = self.x * factor
    self.y = self.y * factor
    self.z = self.z * factor
end 

function mathutils.Vector3:isNear(other, maxdist)
    local distance = self:distance(other)
    return distance < maxdist
end

function mathutils.Vector3:distance(other)
    local dx = other.x - self.x
    local dy = other.y - self.y
    local dz = other.z - self.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function mathutils.Vector3:normalize()
    local length = self:length()
    self.x = self.x / length
    self.y = self.y / length
    self.z = self.z / length
end

function mathutils.Vector3:length()
    local origin = mathutils.Vector3:new(0, 0, 0)
    return origin:distance(self)
end

function mathutils.Vector3:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

function mathutils.Vector3:to(other)
    return mathutils.Vector3:new(other.x - self.x, other.y - self.y, other.z - self.z)
end



mathutils.Vector2 = {}

function mathutils.Vector2:new(x, y)
    local o = {}
    o.x = x
    o.y = y

    setmetatable(o, self)
    self.__index = self
    return o
end

mathutils.lastClampRestrained = false

function mathutils.clamp(value, min, max)
    if value > max then
        mathutils.lastClampRestrained = true
        return max
    elseif value < min then
        mathutils.lastClampRestrained = true
        return min
    end

    mathutils.lastClampRestrained = false
    return value
end

return mathutils