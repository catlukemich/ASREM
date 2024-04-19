local composer     = require("composer")
local iso_view     = require("iso_view")
local iso_sprite   = require("iso_sprite")
local iso_scroller = require("iso_scroller")
local ui_controls  = require("ui_controls")

local scene = composer.newScene();


function scene:create() 
    local isoView = iso_view:new(self.view)
    self.isoView = isoView

    self.terrain = iso_sprite.createFromImage("assets/graphics/terrain.png", 600, 800);
    self.isoView:insert(self.terrain);

    self.isoView:setZoom(1)

    self.terrain:addEventListener("tap", function() isoView:toggleZoom() end)

    self.isoView:enableScrolling();
end

function scene:show()
    
    composer.showOverlay("game_hud");
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