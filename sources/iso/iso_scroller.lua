local view_constants = require("sources.iso.view_constants")
local mathutils = require("sources.mathutils")


local iso_scroller = {}

function iso_scroller:new(isoView, isoGroup) 
    local o = {}
    o.isoView = isoView
    o.isoGroup = isoGroup
    o.startX = 0
    o.startY = 0
    o.keyScrollOffset = mathutils.Vector3:new(0, 0, 0) 
    o.locked = false

    -- A method that is responsible for reading the touch events and scrolling the iso view appropriately.
    o.handleTouchScrolling = function(event) 
        o:moveView(event)
    end

    -- The method that gets run every 20ms and scrolls the iso view by certain amount.
    o.handleKeyScrollng = function (event)
        o:moveViewByKey(event)
    end

    setmetatable(o,self)
    self.__index = self
    return o
end


function iso_scroller:setIsoGroup(isoGroup)
    self.isoGroup = isoGroup
end


function iso_scroller:enable()
    Runtime:addEventListener("touch", self.handleTouchScrolling)
    Runtime:addEventListener("key", self.handleKeyScrollng)
    self.keyScrollTimer = timer.performWithDelay( 20, function ()
        self:scrollByKeyOffset()
    end, 0)
end

function iso_scroller:disable()
    Runtime:removeEventListener("touch", self.handleTouchScrolling)
    Runtime:removeEventListener("key", self.handleKeyScrollng)
    timer.cancel( self.keyScrollTimer )
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
        self.startX = event.x
        self.startY = event.y

        -- Align the isoView's center' location basing on the x and y delta:
        local multiplier = 1 / zoom
        viewCenter.x = viewCenter.x - xDelta / view_constants.HALF_TILE_WIDTH * multiplier / 2 - yDelta / view_constants.HALF_TILE_HEIGHT * multiplier / 2
        viewCenter.y = viewCenter.y + xDelta / view_constants.HALF_TILE_WIDTH * multiplier / 2 - yDelta / view_constants.HALF_TILE_HEIGHT * multiplier / 2
        
        -- Constrain the view:
        local newViewCenter = self:findViewConstrainedCenter(viewCenter)
        viewCenter.x = newViewCenter.x
        viewCenter.y = newViewCenter.y

        self.isoGroup:updatePosition()
    end
end

function iso_scroller:scrollByKeyOffset()
    if self.locked then
        return
    end
    local viewCenter = self.isoView.center
    local zoom = self.isoView.zoom

    -- Align the isoView's center's location basing on the x and y delta:
    local multiplier = 1 / zoom
    viewCenter.x = viewCenter.x + self.keyScrollOffset.x * multiplier
    viewCenter.y = viewCenter.y + self.keyScrollOffset.y * multiplier

    -- Constrain the view:
    local newViewCenter = self:findViewConstrainedCenter(viewCenter)
    viewCenter.x = newViewCenter.x
    viewCenter.y = newViewCenter.y

    self.isoGroup:updatePosition()
end


function iso_scroller:moveViewByKey(event)
    if event.phase == "down" then
        -- Scrolling by keyboard started
        if event.keyName == "left" then
            self.keyScrollOffset = mathutils.Vector3:new(-1, 1, 0) 
        elseif event.keyName == "right" then
            self.keyScrollOffset = mathutils.Vector3:new(1, -1, 0)
        elseif event.keyName == "up" then
            self.keyScrollOffset = mathutils.Vector3:new(-1, -1, 0)
        elseif event.keyName == "down" then
            self.keyScrollOffset = mathutils.Vector3:new(1, 1, 0)
        end
    else -- The key was pressed up.
        if event.keyName == "left" or event.keyName == "right" or event.keyName == "up" or event.keyName == "down" then
            -- Scrolling by keyboard ended.
            self.keyScrollOffset = mathutils.Vector3:new(0, 0, 0) 
        end
    end

    self.keyScrollOffset:multSelf(0.02)
end

function iso_scroller:findViewConstrainedCenter(viewCenter, targetZoom, targetDisplayWidth, targetDisplayHeight)
    local constraints = self.isoView.viewConstraints
    if constraints == nil then
        return viewCenter -- Return the original passed in viewCenter if no constraints on the iso view.
    end
    local zoom = targetZoom or self.isoView.zoom
    targetDisplayWidth = targetDisplayWidth or display.contentWidth
    targetDisplayHeight = targetDisplayHeight or display.contentHeight
    
    local sizeMultiplier = 2 ^ (view_constants.INITIAL_ZOOM - zoom)
    local horizontalMargin = (targetDisplayWidth / 2) * sizeMultiplier
    local verticalMargin = (targetDisplayHeight / 2) * sizeMultiplier
    local center2DXNew, center2DYNew = self.isoView:projectWorld(viewCenter)
    local center2DXMin = constraints.left + horizontalMargin
    local center2DYMin = constraints.top + verticalMargin
    local center2DXMax = constraints.right - horizontalMargin
    local center2DYMax = constraints.bottom - verticalMargin
    
    center2DXNew = mathutils.clamp(center2DXNew, center2DXMin, center2DXMax)
    local wasClampX = mathutils.lastClampRestrained
    center2DYNew = mathutils.clamp(center2DYNew, center2DYMin, center2DYMax)
    local wasClampY = mathutils.lastClampRestrained

    -- If the view area is wider than the constrained area width - set the center x to the horizontal center of the constrained area.
    local constraintsWidth = constraints.right - constraints.left
    local viewAreaWidth = 2 * horizontalMargin
    if viewAreaWidth > constraintsWidth  then
        center2DXNew = (constraints.right + constraints.left) / 2
    end

    -- If the view area is higher than the constrained area height - set the center y to the vertical center of the constrained area.
    local constraintsHeight = constraints.bottom - constraints.top
    local viewAreaHeight = 2 * verticalMargin
    if viewAreaHeight > constraintsHeight then
        center2DYNew = (constraints.bottom + constraints.top) / 2
    end

    local center2DNew = mathutils.Vector2:new(center2DXNew, center2DYNew)
    local newViewCenter = self.isoView:unprojectWorld(center2DNew, viewCenter.z)
    
    return newViewCenter
end

function iso_scroller:unlock()
    self.locked = false
end
    

return iso_scroller