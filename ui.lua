local constants = require("constants")
local widget = require("widget")

local ui = {}

function ui.createTextButton(label, width, height, listener)
    local sheetOptions = {
        frames = {
            { x=0, y=0, width=2, height=2},
            { x=2, y=0, width=36, height=2},
            { x=38, y=0, width=2, height=2},

            { x=0, y=2, width=2, height=36},
            { x=2, y=2, width=36, height=36},
            { x=38, y=2, width=2, height=36},

            { x=0, y=38, width=2, height=2},
            { x=2, y=38, width=36, height=2},
            { x=38, y=38, width=2, height=2},


            { x=0 + 40, y=0, width=2, height=2},
            { x=2 + 40, y=0, width=36, height=2},
            { x=38 + 40, y=0, width=2, height=2},

            { x=0 + 40, y=2, width=2, height=36},
            { x=2 + 40, y=2, width=36, height=36},
            { x=38 + 40, y=2, width=2, height=36},

            { x=0 + 40, y=38, width=2, height=2},
            { x=2 + 40, y=38, width=36, height=2},
            { x=38 + 40, y=38, width=2, height=2},
        },
        sheetContentWidth = 80,
        sheetContentHeight = 40

    }

    local sheet = graphics.newImageSheet("assets/ui/text_button.png", sheetOptions);

    local buttonOptions = {
        label = label,
        onRelease = listener,
        labelColor = { default = constants.outlineColor, over = constants.hoverColor},
        width = width,
        height = height,
        sheet = sheet,
        topLeftFrame = 1,
        topMiddleFrame = 2,
        topRightFrame = 3,
        middleLeftFrame = 4,
        middleFrame = 5,
        middleRightFrame = 6,
        bottomLeftFrame = 7,
        bottomMiddleFrame = 8,
        bottomRightFrame = 9,
        topLeftOverFrame = 10,
        topMiddleOverFrame = 11,
        topRightOverFrame = 12,
        middleLeftOverFrame = 13,
        middleOverFrame = 14,
        middleRightOverFrame = 15,
        bottomLeftOverFrame = 16,
        bottomMiddleOverFrame = 17,
        bottomRightOverFrame = 18,
    }
    local button = widget.newButton(buttonOptions);

    return button
end

function ui.createImageButton(sheetPath, width, height, listener)
    local sheetOptions = {
        frames = {
            {
                x = 0, 
                y = 0,
                width = width, 
                height = height
            },
            {
                x = width + 1, 
                y = 0, 
                width = width, 
                height = height
            }
        },
        sheetContentWidth = width * 2 + 1,
        sheetContentHeight = height
    }
    local sheet = graphics.newImageSheet(sheetPath, sheetOptions);

    local button = widget.newButton({
        sheet = sheet,
        defaultFrame = 1,
        overFrame = 2,
        onRelease = listener
    });

    button.x = 0 
    button.y = 0 

    return button
end

function ui.createLabeledImageButton(sheetPath, label, width, height, listener, fontName, fontSize)
    local group = display.newGroup();
    local imageButton = ui.createImageButton(sheetPath, width, height, listener);
    group:insert(imageButton);
    local fontName = fontName or "assets/fonts/Teko-Bold.ttf";
    local fontSize = fontSize or 16
    local label = display.newText(group, label, 0, 0, fontName, fontSize);
    return group
end

function ui.createImageLabel(imagePath, label, width, height, fontName, fontSize)
    local group = display.newGroup();
    local background = display.newImage(group,imagePath,0,0);
    local fontName = fontName or "assets/fonts/Teko-Bold.ttf";
    local fontSize = fontSize or 16
    local label = display.newText(group, label, 0, 0, fontName, fontSize);
    return group
end

function ui.createSwitch(sheetPath, width, height, listener)
    local options = {
        width = width,
        height = height,
        numFrames = 2,
        sheetContentWidth = width * 2,
        sheetContentHeight = height
    }
    local sheet = graphics.newImageSheet(sheetPath, options);

    local switch = widget.newSwitch({
        style = "checkbox",
        sheet = sheet,
        width = width,
        height = height,
        onPress = listener,
        frameOff = 1,
        frameOn = 2
    })
    return switch

end


-- Layout the elements vertically int the given region, or in the whole screen if region not provided
function ui.layoutElementsVertically(elements, region)
    region = region or { x = 0, y = 0, width = display.contentWidth, height = display.contentHeight}
    local regionHeight = region.height
    local numElements = #elements
    local totalHeight = 0

    for i = 1, #elements do
        totalHeight = totalHeight + elements[i].height
    end
    
    local spaceLeft = regionHeight - totalHeight
    local spacing = spaceLeft / (numElements + 1)

    local currentY = spacing + region.y
    for i = 1, #elements do
        elements[i].y = math.round(currentY + elements[i].height / 2)
        currentY = currentY + elements[i].height + spacing
    end
end


-- Layout the elements vertically int the given region, or in the whole screen if region not provided
function ui.layoutElementsHorizontally(elements, region)
    region = region or { x = 0, y = 0, width = display.contentWidth, height = display.contentHeight}
    local regionWidth = region.width
    local numElements = #elements
    local totalWidth = 0

    for i = 1, #elements do
        totalWidth = totalWidth + elements[i].width
    end
    
    local spaceLeft = regionWidth - totalWidth
    local spacing = spaceLeft / (numElements + 1)

    local currentX = spacing + region.x
    for i = 1, #elements do
        elements[i].x = math.round(currentX + elements[i].width / 2)
        currentX = currentX + elements[i].width + spacing
    end
end

-- Center elements horizontally on the screen
function ui.centerHorizontally(elements)
    local contentWidth = display.contentWidth
    local halfWidth = contentWidth / 2

    for i = 1, #elements do
        elements[i].x = halfWidth
    end
end

function ui.alignTop(element, region)
    region = region or { x = 0, y = 0, width = display.contentWidth, height = display.contentHeight}
    element.y = region.y + element.height / 2    
end

function ui.alignBottom(element, region)
    region = region or { x = 0, y = 0, width = display.contentWidth, height = display.contentHeight}
    element.y = region.y + region.height - element.height / 2    
end

function ui.alignLeft(element, region)
    region = region or { x = 0, y = 0, width = display.contentWidth, height = display.contentHeight}
    element.x = region.x + element.width / 2
end

function ui.alignRight(element, region)
    region = region or { x = 0, y = 0, width = display.contentWidth, height = display.contentHeight}
    element.x = region.x + region.width - element.width / 2
end

return ui
