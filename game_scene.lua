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
    self.isoView:enableScrolling();
end

function scene:show(event)
    if (event.phase == "will") then
        composer.showOverlay("game_hud");
        local sprites = iso_sprite.loadFromMultipleSpritesFile("assets/sprites", "sprites.json")

        local terrain = sprites:get("terrain")
        terrain.layer = -2
        
        self.isoView:insertCollection(sprites)

        Runtime:addEventListener("mouse", function(event) self:onMouseEvent(event) end)

        gestures.enableMultitouchSimulation()
        gestures.addPinchListener(function(scale) self:zoomOnPinch(scale) end)

        local cp1 = mathutils.Vector3:new(-2,0,0)
        local cp2 = mathutils.Vector3:new(0,0,0)
        local cp3 = mathutils.Vector3:new(0,0,0)
        local cp4 = mathutils.Vector3:new(0,2,0)

        local bezier = iso_curve.newCubicBezier(cp1, cp2, cp3, cp4)
        local curve = iso_curve.newDisplayCurve(bezier, self.isoView)
        curve.layer = 2
        self.isoView:insert(curve)
 
        local beziers = iso_curve.parseCurves("assets/curves.json")
        for index, bezier in ipairs(beziers) do
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
 
        self.updateTimer = timer.performWithDelay(30, function() self:update() end, 0)

        print(utils.getLineNumber())
        -- error("nope")
    end
end

function scene:hide(event)
    if event.phase == "did" then
        timer.cancel(self.updateTimer)
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

function scene:update()
    -- print("Update")
    -- print(param)
    self.travelerSprite:update(1)
end


function scene:destroy()
    
end

scene:addEventListener("create" , scene )
scene:addEventListener("show"   , scene )
scene:addEventListener("hide"   , scene )
scene:addEventListener("destroy", scene )




return scene