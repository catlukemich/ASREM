local iso_sprite = require("sources.iso.iso_sprite");
local iso_curve = require("sources.iso.iso_curve");

local entities = {}

function entities.createCar(dirPath)
    local car = display.newGroup()
    iso_sprite.applyIsometricProperties(car)
    iso_curve.makeCurveTraveler(car)
    
    local numDirections = 64    
    local body = iso_sprite.createMultiDirectional(dirPath .. "/" .. "body.png", numDirections, 96, 64)
    local mask = iso_sprite.createMultiDirectional(dirPath .. "/" .. "mask.png", numDirections, 96, 64)
    car:insert(body)
    car:insert(mask)

    -- Most popular car colors (RGB, with percentage):s
    local colors = {
        {1, 1, 1, 0.24},
        {0, 0, 0, 0.23},
        {0.3, 0.3, 0.3, 0.15}, -- Gray
        {0.6, 0.6, 0.6, 0.15},  -- Silver
        {0.27, 0.07, 0.07, 0.1},  -- Brown
        
    }

    -- Generate a random color for the car:
    local randomColor = colors[1]
    for _, color in pairs(colors) do
        local random = math.random(1000)
        local probRange = color[4] * 1000
        if random < probRange then
            randomColor = color
            break
        end
    end
    mask:setFillColor(randomColor[1], randomColor[2], randomColor[3])
    
    -- ---- Apply clouds to the car: TODO: Do this if time allows.
    -- -- Load the masked image:
    -- local clouds = display.newImageRect("/assets/images/clouds.png", 1000, 1000 )
    -- car:insert(clouds)

    -- -- Load the alpha 
    -- local alpha = iso_sprite.createMultiDirectional(dirPath .. "/" .. "alpha.png", numDirections, 96, 64) -- TODO: Refactor the size values into constants or deal with it any other way.

    -- function car:onLocationChange(location)
    --     x, y = self.isoView:project(location, self.isoView)
    --     clouds.fill.x = (-x / 1000)
    --     clouds.fill.y = (-y / 1000)
    --     print(x, y)
    -- end
    
    function car:setRotation(zAxisRotationDegrees)
        local angleBetween = 360 / numDirections
        local index = (math.round(zAxisRotationDegrees  / angleBetween) ) % numDirections + 1
        body:setFrame(index)
        mask:setFrame(index)
    end

    function car:update(time)
        local angle = car:updateTraveler(time)
        
        car:setRotation(angle)
    end
    


    return car
end

return entities