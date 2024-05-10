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


mathutils.Vector2 = {}

function mathutils.Vector2:new(x, y)
    local o = {}
    o.x = x
    o.y = y

    setmetatable(o, self)
    self.__index = self
    return o
end


function mathutils.clamp(value, min, max)
    if value > max then
        return max
    elseif value < min then
        return min
    end

    return value
end

return mathutils