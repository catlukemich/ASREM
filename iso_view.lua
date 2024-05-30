local iso_zoomer = require("iso_zoomer")
local iso_scroller = require("iso_scroller")
local iso_sprite = require("iso_sprite")
local mathutils = require("mathutils")
local view_constants = require("view_constants")
local utils          = require("utils")

local iso_view = {}

iso_view.View = {}

function iso_view.View:new(sceneView)
    local isoView = {}
    
    local group = display.newGroup()
    
    sceneView.name = "Scene View"
    isoView.isoGroup = iso_sprite.createFromObject(group)
    sceneView:insert(isoView.isoGroup)
    
    isoView.collection = iso_sprite.Collection:new()
    
    isoView.zoom = 1 -- The current zoom level: 1 - when zoomed out, 2 - when zoomed in
    isoView.center = {x = 0, y = 0, z = 0}
    
    isoView.isoGroup.isoView = isoView
    
    setmetatable(isoView, self)
    self.__index = self

    isoView.isoGroup:setLocation({x = 0, y = 0, z = 0})

    isoView.isoScroller = iso_scroller:new(isoView, isoView.isoGroup)
    isoView.isoZoomer = iso_zoomer:new(isoView, isoView.isoGroup)
    
    return isoView
end


function iso_view.View:insert(isoSprite)
    isoSprite.isoView = self
    isoSprite:updateBounds()
    isoSprite:updatePosition()
    self.collection:insert(isoSprite)
    self.isoGroup:insert(isoSprite)
    self:sort()
end


--- Returns a collection of sprites that belong to the IsoView.
--This collection should not be modified i.e. no new sprites 
--should be added or removed from the collection (it is read-only).
--@return iso_sprite.Collection The collection of all sprites.
function iso_view.View:getSprites()
    return self.collection
end

---Get collection of all the sprites that are assigned to a layer with a name given as the argument
---@param layerName string The layer name.
---@return table The collection of sprites that are on the layer given by a layerName
function iso_view.View:getLayer(layerName)
    local resultCollection = iso_sprite.Collection:new()

    for _, sprite in pairs(self.collection) do
        if sprite.layerName == layerName then
            resultCollection:insert(sprite)
        end
    end

    return resultCollection
end

function iso_view.View:insertCollection(isoSpriteCollection)
    for key, sprite in pairs(isoSpriteCollection) do 
        self:insert(sprite)
        sprite:updatePosition()
    end
end


function iso_view.View:remove(isoSprite)
    self.collection:remove(isoSprite)
    self.isoGroup:remove(isoSprite)
end


function iso_view.View:setZoom(zoom, doTransition)
    self.isoZoomer:setZoom(zoom, doTransition)
end


function iso_view.View:toggleZoom()
    self.isoZoomer:toggleZoom()
end


function iso_view.View:enableScrolling()
    self.isoScroller:enable()
end


function iso_view.View:disableScrolling()
    self.isoScroller:disable()
end

function iso_view.View:applyMask(mask)
      self.mask = mask
      self.isoGroup:setMask(mask)
end

-- Constrain scrolling of the view to a given 2d coordinates, so that view won't show objects beyond this bounds.
function iso_view.View:constrainViewArea(left, top, right, bottom)
    self.viewConstraints = {left = left, top = top, right = right, bottom = bottom}
end

function iso_view.View:unConstrainViewArea()
    self.viewConstraints = nil
end

-- Utility function from projecting from iso world coordinates to screen coordintates
function iso_view.View:project(location, parent, zoom, center)
    zoom = zoom or self.zoom
    center = center or self.center
    local x, y
    if (parent == nil or (parent and parent.name == "Scene View")) then
        x = (location.x - center.x - location.y + center.y) * view_constants.HALF_TILE_WIDTH * zoom
        y = (location.x - center.x + location.y - center.y) * view_constants.HALF_TILE_HEIGHT * zoom - (location.z - center.z) * view_constants.V_STEP * zoom
        x = x + display.contentWidth / 2
        y = y + display.contentHeight /  2
    else
        x = (location.x - location.y) * view_constants.HALF_TILE_WIDTH 
        y = (location.x  + location.y) * view_constants.HALF_TILE_HEIGHT  - (location.z) * view_constants.V_STEP 
    end
    return x, y
end

-- This function will project a location relative to world center on to 2d coordinates.
-- This means a point that's located in some distance away from the center will get x and y position as if 
-- the view's center was at the same position as the world center.
-- Params:
-- - location - mathutils.Vector3 instance or any table with x, y and z members.
function iso_view.View:projectWorld(location)
    local htw = view_constants.HALF_TILE_WIDTH * view_constants.INITIAL_ZOOM -- The original half tile width.
    local hth = view_constants.HALF_TILE_HEIGHT * view_constants.INITIAL_ZOOM -- and half tile height
    local v_step = view_constants.V_STEP * view_constants.INITIAL_ZOOM -- and vertical step

    local x = (location.x - location.y) * htw
    local y = (location.x + location.y) * hth - (location.z) * v_step
   
    return x, y
end

-- Unproject a flat 2d position to a world location coordintates. 
-- The coordinates are relative to the world center, as if it was in the center of the flat plane the input position exists on.
-- Params:
-- - position - the position to unproject, mathutils.Vector2 instance or any table with x and y members.
-- Returns:
-- - Instance of mathutils.Vector3 
function iso_view.View:unprojectWorld(position, zValue, zoom)
    zoom = zoom or self.zoom
    local htw = view_constants.HALF_TILE_WIDTH * view_constants.INITIAL_ZOOM -- The original half tile width.
    local hth = view_constants.HALF_TILE_HEIGHT * view_constants.INITIAL_ZOOM -- and half tile height
    local v_step = view_constants.V_STEP * view_constants.INITIAL_ZOOM -- and vertical step

    local locationX = (position.x * hth + position.y * htw + hth * v_step * zValue) / (2 * htw * hth)
    local locationY = locationX - position.x / htw

    return mathutils.Vector3:new(locationX, locationY, zValue)
end


function iso_view.View:sort()
    local function sortFunc(sprite1, sprite2)
        local layer1 = sprite1.layer or 0
        local layer2 = sprite2.layer or 0
        if layer1 ~= layer2 then
            return layer1 < layer2
        else
            local nearnes1 = sprite1.location.x + sprite1.location.y + sprite1.location.z
            local nearnes2 = sprite2.location.x + sprite2.location.y + sprite2.location.z
            return nearnes1 < nearnes2
        end
    end

    local group = self.isoGroup
    local objects = {}
    for i = 1, group.numChildren do 
      objects[#objects+1] = group[i]
    end
    table.sort( objects, sortFunc )
    for i = 1, #objects do 
      group:insert( objects[i] ) 
    end

end

return iso_view