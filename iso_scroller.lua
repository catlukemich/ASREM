local constants = require("constants")

local iso_scroller = {}

function iso_scroller:new(isoView, isoGroup) 
    local o = {}
    o.isoView = isoView
    o.isoGroup = isoGroup
    o.startX = 0
    o.startY = 0
    o.locked = false
    o.handleTouch = function(event) 
        o:moveView(event)
    end
    
    setmetatable(o,self)
    self.__index = self
    return o
end

function iso_scroller:setIsoGroup(isoGroup)
    self.isoGroup = isoGroup
end

function iso_scroller:moveView(event)
    if self.locked then return end

    if(event.phase == "began") then
        self.startX = event.x
        self.startY = event.y
    end

    if(event.phase == "moved")  then
        local center = self.isoView.center
        local zoom = self.isoView.zoom
        local xDelta = event.x - self.startX
        local yDelta = event.y - self.startY
        self.startX = event.x
        self.startY = event.y

        local multiplier = 1 / zoom
        center.x = center.x - xDelta / constants.half_tile_width * multiplier / 2 - yDelta / constants.half_tile_height * multiplier / 2
        center.y = center.y + xDelta / constants.half_tile_width * multiplier / 2 - yDelta / constants.half_tile_height * multiplier / 2
        self.isoGroup:updatePosition()
    end
end

function iso_scroller:enable()
    Runtime:addEventListener("touch", self.handleTouch)
end

function iso_scroller:disable()
    Runtime:removeEventListener("touch", self.handleTouch);
end

function iso_scroller:lock()
    self.locked = true
    print("LCOKDSIGNA !!!!")
end

function iso_scroller:unlock()
    self.locked = false
end
    

return iso_scroller