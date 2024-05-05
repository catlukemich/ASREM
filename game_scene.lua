local composer     = require("composer")
local gestures     = require("gestures")
local iso_view     = require("iso_view")
local iso_sprite   = require("iso_sprite")

local scene = composer.newScene();


function scene:create() 
    local isoView = iso_view:new(self.view)
    self.isoView = isoView

    self.isoView:setZoom(1)
    self.isoView:enableScrolling();
end

function scene:show(event)
    if (event.phase == "will") then
        composer.showOverlay("game_hud");
        local sprites = iso_sprite.loadFromMultipleSpritesFile("assets/sprites", "sprites.json")

        local terrain = sprites:get("terrain")
        terrain.layer = -2
        
        self.isoView:insertCollection(sprites)

        gestures.enableMultitouchSimulation()
        gestures.addPinchListener(function(scale) self:zoomOnPinch(scale) end)
    end
end

function scene:onMouseEvent(event)
    if event.type == "scroll" then
        if event.scrollY > 0 then
            self.isoView:setZoom(1, true)
        else
            self.isoView:setZoom(2, true)
        end
    end
end

function scene:zoomOnPinch(pinchScale)
    print(pinchScale)
    if pinchScale > 4 then
        self.isoView:setZoom(2, true)
    elseif pinchScale < 0.4 then
        self.isoView:setZoom(1, true)
    end
end

function scene:hide()
    
end

function scene:destroy()

end

scene:addEventListener("create" , scene )
scene:addEventListener("show"   , scene )
scene:addEventListener("hide"   , scene )
scene:addEventListener("destroy", scene )




return scene