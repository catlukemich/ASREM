local composer     = require("composer")
local constants    = require("constants");
local gestures     = require("gestures")
local iso_view     = require("iso_view")
local iso_sprite   = require("iso_sprite")
local iso_curve    = require("iso_curve")
local entities     = require("entities");
local mathutils    = require("mathutils")
local utils        = require("utils");


local scene = composer.newScene();


function scene:create() 
    self.cars = {}

    local isoView = iso_view.View:new(self.view)
    self.isoView = isoView

    self.isoView:setZoom(1)
end

function scene:show(event)
    if (event.phase == "will") then
        self.lastTime = system.getTimer() / 1000

        composer.showOverlay("game_hud");
        self.isoView:enableScrolling();
        self.isoView:constrainViewArea(-1301, -1154, 1301, 1154)
        
        self:loadSprites()
        self:enableMouseZooming()
        self:enablePinchZooming(true)
        self:loadCurves(false)
        self:startSorting()
        self:startUpdateLoop()
    end
end

function scene:hide(event)
    if event.phase == "did" then
        self.isoView:disableScrolling()
        self:stopSorting()
        self:stopUpdateLoop()
    end
end

function scene:loadSprites()
    --- Create the grass underneath everything:
    local grassSprite = iso_sprite.createFromImage("assets/images/grass.png" , 1301 * 2, 1154 * 2)
    grassSprite.layer = constants.layers["Grass"]
    self.isoView:insert(grassSprite)

    -- Load all the static sprites:
    local sprites = iso_sprite.loadFromMultipleSpritesFile("assets/sprites", "sprites.json")
    sprites:applyLayers(constants.layers)
    self.isoView:insertCollection(sprites)

    -- local trees = sprites:findall("tree")

    local ground = self.isoView:getLayer("Ground")
    ground:setVisible(false)
    -- trees:setVisible(false) 
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
    self.beziers = iso_curve.parseCurves("assets/curves.json")

    -- Debugging code:
    if debug then
        for _, bezier in ipairs(self.beziers) do
            local curve = iso_curve.newDisplayCurve(bezier, self.isoView, 10, true)
            curve.layer = 3
            self.isoView:insert(curve)
        end

    end
end

function scene:startUpdateLoop()
    self.updateTimer = timer.performWithDelay(30, function() self:update() end, 0)
end

function scene:stopUpdateLoop()
    timer.cancel( self.updateTimer )
end


function scene:update()


    local time = system.getTimer() / 1000
    local deltaTime = (time - self.lastTime) * 2
    self.lastTime = time

    if math.random(100) == 1 then
         -- local travelerSprite = iso_sprite.createMultiDirectional("assets/vehicles/dodge/dodge.png",32, 100, 100)
         local car = entities.createCar("assets/vehicles/car1")

         -- travelerSprite:setFillColor(1,0,0,1);
         car.layer = constants.layers["Objects"]
         self.isoView:insert(car)
         car:setCurve(self.beziers[math.random(#self.beziers)])
         table.insert(self.cars, car)
    end

    for i, car in ipairs(self.cars) do
        car:update(deltaTime)
    end
end

function scene:startSorting()
    self.sortTimer = timer.performWithDelay( 300, function ()
        self.isoView:sort()
    end , 0 )
end

function scene:stopSorting()
   timer.cancel(self.sortTimer)
end

function scene:destroy()
    
end

scene:addEventListener("create" , scene )
scene:addEventListener("show"   , scene )
scene:addEventListener("hide"   , scene )
scene:addEventListener("destroy", scene )




return scene