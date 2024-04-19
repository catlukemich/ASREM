local iso_zoomer = require("iso_zoomer")
local iso_scroller = require("iso_scroller")
local iso_sprite = require("iso_sprite")

local iso_view = {}

function iso_view:new(sceneView)
    local o = {}
    local group = display.newGroup()    
    
    sceneView.name = "view"
    o.isoGroup = iso_sprite.createFromObject(group)

    sceneView:insert(o.isoGroup)

    o.zoom = 1 -- The current zoom level: 1 - when zoomed out, 2 - when zoomed in
    o.center = {x = 0, y = 0, z = 0}
    
    o.isoGroup.isoView = o
    o.isoGroup:setLocation(0, 0, 0)
    
    o.isoScroller = iso_scroller:new(o, o.isoGroup)
    o.isoZoomer = iso_zoomer:new(o, o.isoGroup)
            
    setmetatable(o,self)
    self.__index = self
    return o
end

function iso_view:insert(isoSprite)
    isoSprite.isoView = self
    isoSprite:updateBounds()
    isoSprite:updatePosition()
    self.isoGroup:insert(isoSprite)
end

function iso_view:remove(isoSprite)
    self.isoGroup:remove(isoSprite)
end

function iso_view:setZoom(zoom)
    self.isoZoomer:setZoom(zoom)
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

return iso_view