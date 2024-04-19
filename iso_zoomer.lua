local widget = require("widget")
local iso_sprite = require("iso_sprite")

local iso_zoomer = {}

function iso_zoomer:new(isoView, isoGroup)
    local o = {}
    o.isoView = isoView
    o.isoGroup = isoGroup

    -- local center = o.isoView.center
    -- local newX, newY = iso_sprite.project(isoGroup.location.x - center.x, isoGroup.location.y - center.y, isoGroup.location.z - center.z, 1)
    -- isoGroup.x = newX
    -- isoGroup.y = newY
    -- isoGroup.xScale = 1
    -- isoGroup.yScale = 1

    setmetatable(o, self)
    self.__index = self
    return o
end

function iso_zoomer:toggleZoom()
    if(self.isoView.zoom == 1) then
        self:setZoom(2, true)
    else 
        self:setZoom(1, true)
    end
end

function iso_zoomer:setZoom(targetZoom, doTransition)
    local isoGroup = self.isoGroup
    local center = self.isoView.center

    if (targetZoom == 2) then
        self.isoView.zoom = 2
        local newX, newY = iso_sprite.project(isoGroup.location, center, targetZoom)


        if doTransition then
            transition.to(isoGroup,{
                x = newX,
                y = newY,
                xScale = 1,
                yScale = 1,
                transition = easing.inOutCubic 
            })
        else
            isoGroup.x = newX
            isoGroup.y = newY
            isoGroup.xScale = 1
            isoGroup.yScale = 1
        end
    else 
        self.isoView.zoom = 1
        local newX, newY = iso_sprite.project(isoGroup.location, center, targetZoom)

        if doTransition then
            transition.to(isoGroup,{
                x = newX,
                y = newY,
                xScale = 0.5,
                yScale = 0.5,
                transition = easing.inOutCubic 
            })
        else
            isoGroup.x = newX
            isoGroup.y = newY
            isoGroup.xScale = 0.5
            isoGroup.yScale = 0.5
        end
    end
end

return iso_zoomer