local constants = require("constants")
local iso_zoomer = require("iso_zoomer")
local iso_scroller = require("iso_scroller")
local iso_sprite = require("iso_sprite")
local iso_view = {}

function iso_view:new(sceneView)
    local o = {}
    local group = display.newGroup()

    sceneView.name = "Scene View"
    o.isoGroup = iso_sprite.createFromObject(group)

    sceneView:insert(o.isoGroup)

    o.zoom = 1 -- The current zoom level: 1 - when zoomed out, 2 - when zoomed in
    o.center = {x = 0, y = 0, z = 0}

    o.isoGroup.isoView = o
    
    setmetatable(o,self)
    self.__index = self

    o.isoGroup:setLocation({x = 0, y = 0, z = 0})

    o.isoScroller = iso_scroller:new(o, o.isoGroup)
    o.isoZoomer = iso_zoomer:new(o, o.isoGroup)
    
    return o
end

function iso_view:insert(isoSprite)
    isoSprite.isoView = self
    isoSprite:updateBounds()
    isoSprite:updatePosition()
    self.isoGroup:insert(isoSprite)
    self:sort()
end



function iso_view:insertCollection(isoSpriteCollection)
    for key, sprite in pairs(isoSpriteCollection) do 
        if type(sprite) == "table" then
            print("inserting:" .. sprite.name)
            self:insert(sprite)
            sprite:updatePosition()
        end
    end
end



function iso_view:remove(isoSprite)
    self.isoGroup:remove(isoSprite)
end

function iso_view:setZoom(zoom, doTransition)
    self.isoZoomer:setZoom(zoom, doTransition)
end

function iso_view:toggleZoom()
    self.isoZoomer:toggleZoom()
end

function iso_view:enableScrolling()
    self.isoScroller:enable()
end

function iso_view:disableScrolling()
    self.isoScroller:disable()
end

-- Utility function from projecting from iso world coordinates to screen coordintates
function iso_view:project(location, parent, zoom)
    local center = self.center
    local zoom = zoom or self.zoom
    local x, y
    if (parent == nil or (parent and parent.name == "Scene View")) then
        x = (location.x - center.x - location.y + center.y) * constants.half_tile_width * zoom
        y = (location.x - center.x + location.y - center.y) * constants.half_tile_height * zoom - (location.z - center.z) * constants.vertical_step * zoom
        x = x + display.contentWidth / 2
        y = y + display.contentHeight /  2
    else
        x = (location.x - location.y) * constants.half_tile_width 
        y = (location.x  + location.y) * constants.half_tile_height  - (location.z) * constants.vertical_step 
    end
    return x, y
end



function iso_view:sort()
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