local mathutils = require("sources.mathutils")


local clouds_animator = {}

clouds_animator.Animator = {}

function clouds_animator.Animator:new(cloudsCollection)
    local o = {}

    o.bezierTime = 0
    o.cloudsCollection = cloudsCollection
    o.windVectorAngle = 0

    local currentT = 0
    for _, cloud in pairs(cloudsCollection) do
        cloud.t = currentT
        local randomOffsetX = math.random() * 10
        local randomOffsetY = math.random() * 10
        cloud.randomOffsetX = randomOffsetX
        cloud.randomOffsetY = randomOffsetY

        currentT = currentT + 0.02
    end
    
    setmetatable(o, self)
    self.__index = self
    
    o:updateBezier(0)

    return o
end


function clouds_animator.Animator:updateBezier(deltaTime)
    local x1 = math.sin(math.rad(self.windVectorAngle)) * 20
    local y1 = math.cos(math.rad(self.windVectorAngle)) * 20

    local x2 = -x1
    local y2 = -y1

    self.cp1 = mathutils.Vector3:new(x1, y1, 0)
    self.cp2 = mathutils.Vector3:new(x2, y2, 0)

    self.bezier = mathutils.CubicBezier:new(self.cp1, self.cp1, self.cp2, self.cp2)

    local randAngleChange = ((math.random() - 0.5) / 10 + math.sin(self.bezierTime * 0.001))  / 100
    self.windVectorAngle = self.windVectorAngle + randAngleChange
    print(self.windVectorAngle)

    self.bezierTime = self.bezierTime + deltaTime
end

function clouds_animator.Animator:update(deltaTime)
    self:updateBezier(deltaTime)

    for _, cloud in pairs(self.cloudsCollection) do
        local location = self.bezier:interpolate(cloud.t)
        location.x = location.x + cloud.randomOffsetX
        location.y = location.y + cloud.randomOffsetY
        cloud.t = cloud.t + 0.001 * deltaTime
        if cloud.t > 1 then
            cloud.t = 0
        end
        cloud:setLocation(location)
    end

    
end

function clouds_animator.update()
    
end

return clouds_animator