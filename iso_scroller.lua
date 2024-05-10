local constants = require("constants")
local mathutils = require("mathutils")

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


function iso_scroller:enable()
    Runtime:addEventListener("touch", self.handleTouch)
end


function iso_scroller:disable()
    Runtime:removeEventListener("touch", self.handleTouch);
end


function iso_scroller:lock()
    self.locked = true
end

function iso_scroller:constrain(constraints)
    self.constraints = constraints
end

function iso_scroller:unconstrain()
    self.constraints = nil
end

function iso_scroller:moveView(event)
    if self.locked then 
        self.startX = event.x
        self.startY = event.y
        return
    end

    if(event.phase == "began") then
        self.startX = event.x
        self.startY = event.y
    end

    if(event.phase == "moved")  then
        local viewCenter = self.isoView.center
        local zoom = self.isoView.zoom
        local xDelta = event.x - self.startX
        local yDelta = event.y - self.startY
        print(xDelta .. " " .. yDelta)
        self.startX = event.x
        self.startY = event.y


      

        -- Align the isoView's center' location basing on the x and y delta:
        local multiplier = 1 / zoom
        local oldCenterX = viewCenter.x
        local oldCentery = viewCenter.y
        viewCenter.x = viewCenter.x - xDelta / constants.HALF_TILE_WIDTH * multiplier / 2 - yDelta / constants.HALF_TILE_HEIGHT * multiplier / 2
        viewCenter.y = viewCenter.y + xDelta / constants.HALF_TILE_WIDTH * multiplier / 2 - yDelta / constants.HALF_TILE_HEIGHT * multiplier / 2
        
        -- Constrain the view:
        local center2DX, center2DY = self.isoView:projectWorld(viewCenter)
        local left =    center2DX - ((display.contentWidth / 2) * (1/zoom))
        local top =     center2DY - ((display.contentHeight / 2) * (1/zoom))
        local right =   center2DX + ((display.contentWidth / 2) * (1/zoom))
        local bottom =  center2DY + ((display.contentHeight / 2) * (1/zoom))

        local constraints = self.isoView.viewConstraints

        if constraints then
            if left > constraints.minX and right < constraints.maxX and top > constraints.minY and bottom < constraints.maxY then
                    -- Do nothing, we're fine scrolling - I'm too lazy to negate the above condition in parentheses
            else
                local newViewCenter = self:findViewConstrainedCenter(viewCenter)
                viewCenter.x = newViewCenter.x
                viewCenter.y = newViewCenter.y
            end
        end

        self.isoGroup:updatePosition()
    end
end

function iso_scroller:findViewConstrainedCenter(viewCenter, targetZoom, targetDisplayWidth, targetDisplayHeight)
    local constraints = self.isoView.viewConstraints
    if constraints == nil then
        return viewCenter -- Return the original passed in viewCenter if no constraints on the iso view.
    end
    local zoom = targetZoom or self.isoView.zoom
    targetDisplayWidth = targetDisplayWidth or display.contentWidth
    targetDisplayHeight = targetDisplayHeight or display.contentHeight
    local center2DXNew, center2DYNew = self.isoView:projectWorld(viewCenter)
    local center2DXMin = constraints.minX + ((targetDisplayWidth / 2) * (1/zoom))
    local center2DYMin = constraints.minY + ((targetDisplayHeight / 2) * (1/zoom))
    local center2DXMax = constraints.maxX - ((targetDisplayWidth / 2) * (1/zoom))
    local center2DYMax = constraints.maxY - ((targetDisplayHeight / 2) * (1/zoom))
    
    center2DXNew = mathutils.clamp(center2DXNew, center2DXMin, center2DXMax)
    center2DYNew = mathutils.clamp(center2DYNew, center2DYMin, center2DYMax)
    
    local center2DNew = mathutils.Vector2:new(center2DXNew, center2DYNew)
    
    local newViewCenter = self.isoView:unprojectWorld(center2DNew, viewCenter.z)
    
    return newViewCenter
end

function iso_scroller:unlock()
    self.locked = false
end
    

return iso_scroller