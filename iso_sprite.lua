local constants = require("constants")
local mathutils = require("mathutils")
local json = require("json")

local utils = require("utils");


local iso_sprite = {}

function iso_sprite.loadFromMultipleSpritesFile(directoryPath, spritesFilename)
    local filepath = spritesFilename and directoryPath .. "/" .. spritesFilename or directoryPath -- Selection operator, kinda

    local pathForFile = system.pathForFile(filepath)
    local decodedJSON = json.decodeFile(pathForFile)
    if decodedJSON == nil then
        error("Cant load multiple sprites from path: " .. filepath )
    end

    local collection = iso_sprite.Collection:new()

    for _, spriteData in pairs(decodedJSON) do
        local sprFileName = spriteData.sprfile
        local sprite = iso_sprite.loadFromSingleSpriteFile(directoryPath, sprFileName)
        collection:insert(sprite)
    end

    return collection
end


-- Create an iso sprite form a .str file 
-- Such a file descibes the:
-- - Path to the sprite's image
-- - Anchor of the image
-- - Location of the sprite in the world coordintates
function iso_sprite.loadFromSingleSpriteFile(directoryPath, sprFilename) 
    local filepath = sprFilename and directoryPath .. "/" .. sprFilename or directoryPath -- Selection operator, kinda
    directoryPath = utils.getDirpath(filepath)

    local decodedJSON = json.decodeFile(filepath)
    if decodedJSON == nil then
        error("Cant load sprite from path: " .. filepath )
    end
    local imagePath  = directoryPath .. "/" .. decodedJSON.image
    local location = decodedJSON.location
    local anchor = decodedJSON.anchor
    local size = decodedJSON.size
    local sprite = iso_sprite.createFromImage(imagePath, size.width, size.height)
    sprite.name = decodedJSON.name
    sprite.layerName = decodedJSON.layer_name
    sprite.anchorX = anchor.anchorX
    sprite.anchorY = anchor.anchorY
    sprite:setLocation(location)
    return sprite
end


function iso_sprite.createMultiDirectional(sheetFilepath, numDirections, imageWidth, imageHeight)
    local iso_curve = require("iso_curve")

    local imageSheet = graphics.newImageSheet( sheetFilepath, {
        width = imageWidth,
        height = imageHeight,
        numFrames = numDirections,

        sheetContentWidth = imageWidth * numDirections,
        sheetContentHeight = imageHeight
    } )

    local sprite = display.newSprite( imageSheet, {
        start = 1,
        count = numDirections,
        time = 100, -- Whatever.. The current frame will never change as the animation will be always paused.
        loopCount = 0
    })
    iso_sprite.applyIsometricProperties(sprite)

    function sprite:setRotation(zAxisRotationDegrees)
        local angleBetween = 360 / numDirections
        local index = (math.round(zAxisRotationDegrees  / angleBetween) ) % numDirections + 1
        -- print(index)
        sprite:setFrame(index)
    end
    
    sprite:pause()

    local traveler = iso_curve.makeCurveTraveler(sprite)

    function traveler:update(time)
        local angle = traveler:updateTraveler(time)
        traveler:setRotation(angle)
    end

    return traveler
end


-- Create sprite from animation - that is a spritesheet given by a certain path and its frame width, 
-- height and the number of frames that spritesheet has. Returns an iso sprite with a running animation. 
function iso_sprite.createFromAnimation(sheetPath, frameWidth, frameHeight, numFrames)
    local animationSheet = graphics.newImageSheet(sheetPath, {
        width = frameWidth,
        height = frameHeight,
        numFrames = numFrames,
        sheetContentWidth = frameWidth * numFrames,
        sheetContentHeight = frameHeight
    });

    if animationSheet == nil then
        error("Can't load image sheet from file: " .. sheetPath)
    end

    local sequence = {
        start = 1,
        count = numFrames,
        time = numFrames * 50,
        loopCount = 0
    }

    local displayObject = display.newSprite(animationSheet, sequence);
    iso_sprite.applyIsometricProperties(displayObject)
    displayObject:setBounds(1, 1, 1)
    displayObject:setLocation(mathutils.Vector3:new(0, 0, 0))
    return displayObject
end

-- Create an iso sprite that just displays a single image.
function iso_sprite.createFromImage(path, width, height)
    local displayObject = display.newImageRect(path,width,height);
    if displayObject == nil then
        error("Can't load image from file: " .. path)
    end
    iso_sprite.applyIsometricProperties(displayObject)
    displayObject:setBounds(1, 1, 1)
    displayObject:setLocation(mathutils.Vector3:new(0, 0, 0))
    return displayObject
end

-- Make an existing object an iso sprite and return it
function iso_sprite.createFromObject(object)
    iso_sprite.applyIsometricProperties(object)
    object:setBounds(1, 1, 1)
    object:setLocation(mathutils.Vector3:new(0, 0, 0))
    return object
end


function iso_sprite.applyIsometricProperties(displayObject) 
    displayObject.location = mathutils.Vector3:new(0, 0, 0)

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

    function displayObject:setLocation(location)
        self.location = location
        self:updateBounds()
        self:updatePosition()
        self:onLocationChange(location)
    end

    function displayObject:onLocationChange(newLocation)
        --   Abstract
    end

    function displayObject:updatePosition()
        if (self.isoView ~= nil) then
            local location = self.location
            local parent = self.parent

            local posX, posY = self.isoView:project(location, parent)
            self.x = posX
            self.y = posY
        end
    end

end


iso_sprite.Collection = {}

function iso_sprite.Collection:new() 
    local collection = {}
    setmetatable(collection, self)
    self.__index = self
    return collection
end

function iso_sprite.Collection:insert(sprite)
    local spriteName = sprite.name
    if spriteName ~= nil then 
        self[spriteName] = sprite
    else
        table.insert(self, sprite)
    end
end

function iso_sprite.Collection:get(spriteName)
    local sprite = self[spriteName]
    if sprite == nil then
        error("No sprite named " .. spriteName);
    end

    return sprite
end

---Find all sprites that match the passed in string and return it
--as a subcollection.
---@param pattern string The pattern to match against the names 
function iso_sprite.Collection:findall(pattern)
    local resultCollection = iso_sprite.Collection:new()

    for name, sprite in pairs(self) do
        if string.find( name, pattern ) then
            resultCollection:insert(sprite)
        end
    end

    return resultCollection
end

function iso_sprite.Collection:remove(sprite)
    local spriteName = sprite.name
    if spriteName ~= nil then 
        self[spriteName] = nil
    else
        table.remove(self, sprite)
    end 
end

--- Apply each object in the collection a layer.
-- The layer index is taken from the layers dictionary object that maps from layer name to it's index.
-- Every sprite in the collection must have a layer property that holds the name of the layer the object
-- appears on.
---@param layers table A table that maps from layer name to it's display order index.
function iso_sprite.Collection:applyLayers(layers)
    for _, sprite in pairs(self) do
        sprite.layer = layers[sprite.layerName]
    end
end


function iso_sprite.Collection:setVisible(visible)
    for _, sprite in pairs(self) do
        sprite.isVisible = visible
    end
end


return iso_sprite

