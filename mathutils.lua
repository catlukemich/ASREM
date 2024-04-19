local mathutils = {}

function mathutils:newVector3(x, y, z)
    local o = {}
    o.x = x 
    o.y = y 
    o.z = z

    setmetatable(o, self)
    self.__index = self
    return o
end

return mathutils