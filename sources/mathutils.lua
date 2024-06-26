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

function mathutils.Vector3:copy()
    return mathutils.Vector3:new(self.x, self.y, self.z)
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


mathutils.QuadraticBezier = {}

function mathutils.QuadraticBezier:new(cp1, cp2, cp3)
    -- Where control points are tables created by call to mathutils.newVector3

    local bezier = {
        cp1 = cp1,
        cp2 = cp2,
        cp3 = cp3
    }

    function bezier:interpolate(t)
        local location = mathutils.Vector3:new(
            (1 - t) * ((1-t) * self.cp1.x + t * self.cp2.x) + t * ((1 - t) * self.cp2.x + t * self.cp3.x),
            (1 - t) * ((1-t) * self.cp1.y + t * self.cp2.y) + t * ((1 - t) * self.cp2.y + t * self.cp3.y),
            (1 - t) * ((1-t) * self.cp1.z + t * self.cp2.z) + t * ((1 - t) * self.cp2.z + t * self.cp3.z)
        )
        return location
    end

    return bezier
end


mathutils.CubicBezier = {}

function mathutils.CubicBezier:new(cp1, cp2, cp3, cp4)
    -- Where control points are tables created by call to mathutils.newVector3
    local bezier = {
        cp1 = cp1,
        cp2 = cp2,
        cp3 = cp3,
        cp4 = cp4
    }

    function bezier:interpolate(t)
        local quadraticBezier1 = mathutils.QuadraticBezier:new(self.cp1, self.cp2, self.cp3)
        local quadraticBezier2 = mathutils.QuadraticBezier:new(self.cp2, self.cp3, self.cp4)
    
        local itpl1 = quadraticBezier1:interpolate(t)
        local itpl2 = quadraticBezier2:interpolate(t)

        local location = mathutils.Vector3:new(
            (1 - t) * itpl1.x + t * itpl2.x,
            (1 - t) * itpl1.y + t * itpl2.y,
            (1 - t) * itpl1.z + t * itpl2.z
        )
        return location
    end

    return bezier
end

return mathutils