local constants = require("constants")

local iso_scroller = {}

function iso_scroller:new(isoView, isoGroup) 
    local o = {}
    o.isoView = isoView
    o.isoGroup = isoGroup
    o.startX = 0
    o.startY = 0
    o.handleTouch = function(event) 
        o:moveView(event)
    end
    
    local rect = display.newRect(0,0,4,4);
    rect:setFillColor(1,0,0,1);
    self.rect = rect

    setmetatable(o,self)
    self.__index = self
    return o
end

function iso_scroller:setIsoGroup(isoGroup)
    self.isoGroup = isoGroup
end

function iso_scroller:moveView(event)
    if(event.phase == "began") then
        self.startX = event.x
        self.startY = event.y
    end

    if(event.phase == "moved") then
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

return iso_scroller