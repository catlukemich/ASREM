local constants = require("constants")
local mathutils = require("mathutils")

iso_sprite = {}

function iso_sprite.createFromAnimation(sheetPath, frameWidth, frameHeight, numFrames)
    local animationSheet = graphics.newImageSheet(sheetPath, {
        width = frameWidth,
        height = frameHeight,
        numFrames = numFrames,
        sheetContentWidth = frameWidth * numFrames,
        sheetContentHeight = frameHeight
    });

    local sequence = {
        start = 1,
        count = numFrames,
        time = numFrames * 50,
        loopCount = 0
    }

    local displayObject = display.newSprite(animationSheet, sequence);
    applyIsometricProperties(displayObject)
    displayObject:setBounds(1, 1, 1)
    displayObject:setLocation(0, 0, 0)
    return displayObject
end

function iso_sprite.createFromImage(path, width, height)
    local displayObject = display.newImageRect(path,width,height);
    applyIsometricProperties(displayObject)
    displayObject:setBounds(1, 1, 1)
    displayObject:setLocation(0, 0, 0)
    return displayObject
end

-- Make an existing object an iso sprite and return it
function iso_sprite.createFromObject(object)
    applyIsometricProperties(object)
    object:setBounds(1, 1, 1)
    object:setLocation(0, 0, 0)
    return object
end

function iso_sprite.createMultiDirectional()
    -- TODO
end

function applyIsometricProperties(displayObject) 
    displayObject.location = mathutils:newVector3(0, 0, 0)

    displayObject.boundsWidth  = 1
    displayObject.boundsDepth  = 1
    displayObject.boundsHeight = 1

    function displayObject:updateBounds()
        self.minX = self.location.x - self.boundsWidth / 2
        self.maxX = self.location.x + self.boundsWidth / 2
        self.minY = self.location.y - self.boundsDepth / 2
        self.maxY = self.location.y + self.boundsDepth / 2
        self.minZ = self.location.z - self.boundsHeight / 2
        self.maxZ = self.location.z + self.boundsHeight / 2
    end

    function displayObject:setBounds(boundsWidth, boundsDepth, boundsHeight)
        self.boundsWidth  = boundsWidth
        self.boundsDepth  = boundsDepth
        self.boundsHeight = boundsHeight
        self:updateBounds()
    end

    function displayObject:setLocation(x, y, z)
        self.location.x = x
        self.location.y = y
        self.location.z = z
        self:updateBounds()

        self:updatePosition()
    end

    function displayObject:updatePosition()
        if (self.isoView ~= nil) then
            local location = self.location
            local center = self.isoView.center
            local zoom = self.isoView.zoom
            local parent = self.parent

            local posX, posY = iso_sprite.project(location, center,  zoom, parent)
            self.x = posX
            self.y = posY
        end
    end

end


-- Utility function from projecting from iso world coordinates to screen coordintates
function iso_sprite.project(location, center, zoom, parent)
    local x = (location.x - center.x - location.y + center.y) * constants.half_tile_width * zoom
    local y = (location.x - center.x + location.y - center.y) * constants.half_tile_height * zoom - (location.z - center.z) * constants.vertical_step * zoom
    if (parent == nil or (parent and parent.name == "view")) then
        x = x + display.contentWidth / 2
        y = y + display.contentHeight /  2
    end
    return x, y
end


return iso_sprite

