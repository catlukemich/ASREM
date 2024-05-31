local iso_collection = {}

iso_collection.Collection = {}

function iso_collection.Collection:new() 
    local collection = {}
    setmetatable(collection, self)
    self.__index = self
    return collection
end

function iso_collection.Collection:insert(sprite)
    local spriteName = sprite.name
    if spriteName ~= nil then 
        self[spriteName] = sprite
    else
        table.insert(self, sprite)
    end
end

function iso_collection.Collection:get(spriteName)
    local sprite = self[spriteName]
    if sprite == nil then
        error("No sprite named " .. spriteName);
    end

    return sprite
end

---Find all sprites that match the passed in string and return it
--as a subcollection.
---@param pattern string The pattern to match against the names 
function iso_collection.Collection:findall(pattern)
    local resultCollection = iso_collection.Collection:new()

    for name, sprite in pairs(self) do
        if string.find( name, pattern ) then
            resultCollection:insert(sprite)
        end
    end

    return resultCollection
end

function iso_collection.Collection:remove(sprite)
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
function iso_collection.Collection:applyLayers(layers)
    for _, sprite in pairs(self) do
        sprite.layer = layers[sprite.layerName]
    end
end


function iso_collection.Collection:setVisible(visible)
    for _, sprite in pairs(self) do
        sprite.isVisible = visible
    end
end

---Set the alpha of all the sprites in the collection.
---@param alpha number The value between 0 and 1.
function iso_collection.Collection:setAlpha(alpha)
    for _, sprite in pairs(self) do
        sprite.alpha = alpha
    end
end


return iso_collection