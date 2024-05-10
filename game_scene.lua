local composer     = require("composer")
local gestures     = require("gestures")
local iso_view     = require("iso_view")
local iso_sprite   = require("iso_sprite")
local iso_curve = require("iso_curve")
local mathutils = require("mathutils")
local utils = require("utils");

local scene = composer.newScene();


function scene:create() 
    local isoView = iso_view:new(self.view)
    self.isoView = isoView

    self.isoView:setZoom(1)
end

function scene:show(event)
    if (event.phase == "will") then
        composer.showOverlay("game_hud");
        self.isoView:enableScrolling();
        self.isoView:constrainViewArea(-1345 / 3, -1794 / 3, 1345 / 3, 1794 / 3)
        
        self:loadSprites()
        self:enableMouseZooming()
        self:enablePinchZooming(true)
        self:loadCurves(true)
        self:runUpdateLoop()
    end
end

function scene:hide(event)
    if event.phase == "did" then
        timer.cancel(self.updateTimer)
    end
end

function scene:loadSprites()
    -- -- Create the grass underneath everything:
    -- local grassTexture = graphics.newTexture({type = "image", filename = "assets/images/grass_texture.png"} )
    -- local grass = display.newRect(0, 0, 5000, 5000)
    -- grass.fill = {
    --     type = "image",
    --     filename = grassTexture.filename,
    --     baseDir = grassTexture.baseDir,
    -- }
    -- grass.fill.scaleX = 0.4
    -- grass.fill.scaleY = 0.4
    -- local grassSprite = iso_sprite.createFromObject(grass)
    -- grassSprite.layer = -10
    -- self.isoView:insert(grassSprite)

    local grassSprite = iso_sprite.createFromImage("assets/images/grass.png" , 1345 * 2, 1794 * 2 )
    self.isoView:insert(grassSprite)

    -- Load all the static sprites:
    local sprites = iso_sprite.loadFromMultipleSpritesFile("assets/sprites", "sprites.json")
    self.isoView:insertCollection(sprites)
end

function scene:enableMouseZooming()
    self.zoomFunction = function (event)
        if event.type == "scroll" then
            if event.scrollY > 0 then
                self.isoView:setZoom(1, true)
            else
                self.isoView:setZoom(2, true)
            end
        end
    end

    Runtime:addEventListener("mouse", self.zoomFunction)
end

function scene:enablePinchZooming(simulate)
    self.zoomOnPinch = function(pinchScale)
        print(pinchScale)
        if pinchScale > 4 then
            self.isoView:setZoom(2, true)
        elseif pinchScale < 0.4 then
            self.isoView:setZoom(1, true)
        end
    end
    if simulate then
        gestures.enableMultitouchSimulation()
    end

    gestures.addPinchListener(self.zoomOnPinch)
end

function scene:loadCurves(debug)
    local beziers = iso_curve.parseCurves("assets/curves.json")

    -- Debugging code:
    if debug then
        for _, bezier in ipairs(beziers) do
            local curve = iso_curve.newDisplayCurve(bezier, self.isoView, 10, true)
            curve.layer = 3
            self.isoView:insert(curve)
        end

        local travelerSprite = display.newRect(-10, -10, 20, 20)
        travelerSprite.layer = 2
        iso_sprite.applyIsometricProperties(travelerSprite)
        iso_curve.makeCurveTraveler(travelerSprite)
        self.isoView:insert(travelerSprite)
        print(beziers[1])
        travelerSprite:setCurve(beziers[4])
        self.travelerSprite = travelerSprite
    end
end

function scene:runUpdateLoop()
    self.updateTimer = timer.performWithDelay(30, function() self:update() end, 0)
end

function scene:update()
    self.travelerSprite:update(1)
end


function scene:destroy()
    
end

scene:addEventListener("create" , scene )
scene:addEventListener("show"   , scene )
scene:addEventListener("hide"   , scene )
scene:addEventListener("destroy", scene )




return scene