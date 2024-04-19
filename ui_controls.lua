local ui = require("ui");
local widget = require("widget");

local ui_controls = {};

-- iconFilename - the file name of an icon file located in "assets/ui/actions/" directory
function ui_controls.createCostActionButton(iconFilename, width, height, label, cost, listener)
    local group = display.newGroup();
    
    local fontName = fontName or "assets/fonts/Teko-Bold.ttf";

    local fontSize = 20
    local buttonLabel = display.newText(label, 0, 0, fontName, fontSize);
    buttonLabel.x = 45
    buttonLabel.y = 25

    local filePath = "assets/graphics/ui/actions/" .. iconFilename;
    local buttonIcon = display.newImageRect(filePath, width, height);
    buttonIcon.x = 116
    buttonIcon.y = 23

    fontSize = 14
    local costLabel  = display.newText(tostring(cost), 0, 0, fontName, fontSize);
    costLabel:setFillColor(1,1,1);
    costLabel.x = 45
    costLabel.y = 49

    local buttonBackground = ui.createImageButton("assets/graphics/ui/actions/action_button_background.png", 140, 48, listener);
    local costBackground = display.newImageRect("assets/graphics/ui/actions/action_cost_background.png", 112, 22)
    costBackground.x = 56
    costBackground.y = 48

    group:insert(costBackground)
    group:insert(buttonBackground);
    group:insert(buttonLabel)
    group:insert(buttonIcon)
    group:insert(costLabel)

    function group:setCost(cost)
        costLabel.text = tostring(cost)
    end

    return group
end


function ui_controls.createLabeledSlider(label, width, listener)
    local group = display.newGroup();

    local background = display.newImageRect("assets/graphics/ui/slider/slider_background.png", width + 80, 40)
    background.x = (width + 80) / 2
    group:insert(background)

    local sheetOptions = {
        width = 10,
        height = 24,
        numFrames = 5,
        sheetContentWidth = 50,
        sheetContentHeight = 24
    }

    local sheet = graphics.newImageSheet("assets/graphics/ui/slider/slider_sheet.png", sheetOptions)
    
    local sliderOptions = {
        sheet = sheet,
        x = width / 2 + 80,
        y = 0,
        leftFrame = 1,
        middleFrame = 2,
        fillFrame = 3,
        rightFrame = 4,
        handleFrame = 5,
        frameWidth = 10,
        frameHeight = 24,
        handleWidth = 10,
        handleHeight = 24,

        orientation = "horizontal",
        width = width,
        listener = listener
    }
    local slider = widget.newSlider(sliderOptions);

    group:insert(slider)

    local fontName = "assets/fonts/Teko-Regular.ttf";
    local fontSize = 18
    local sliderLabel = display.newText(label, 0, 0, fontName, fontSize);
    sliderLabel.x = 40
    sliderLabel.y = 2
    group:insert(sliderLabel)

    function group:setLabel(label)
        sliderLabel.text = label
    end

    function group:getValue()
        return slider.value
    end

    return group
end

function ui_controls.createStatusBar() 
    local group = display.newGroup()

    local width = 300
    local background = display.newImageRect("assets/graphics/ui/statusbar/background.png", width, 26);
    background.x = width / 2
    group:insert(background)

    local fontName = "assets/fonts/Teko-Regular.ttf"
    local fontSize = 18
    local label = display.newText("Status bar", 0, 0, fontName, fontSize)
    label.x = width / 2 - 20
    group:insert(label)

    return group
end


function ui_controls.createFundsGauge(chartButtonListener)
    local group = display.newGroup();
    
    local fontName = "assets/fonts/Teko-Regular.ttf"
    local fontSize = 20
    local label = display.newText("Funds: $1000", 0, 0, fontName, fontSize)
    label.x = 0
    print(label.height)
    label:setFillColor(1,1,1);

    local chartButton = ui.createImageButton("assets/graphics/ui/funds_gauge/chart_button.png", 24, 24, chartButtonListener)
    chartButton.x = 68
    chartButton.y = 0

    local background = display.newImageRect("assets/graphics/ui/funds_gauge/background.png", 196, 30);
    

    group:insert(background)
    group:insert(chartButton)
    group:insert(label)

    function group:setFundds(funds)
          label.text = "Funds: $" .. toString(funds)
    end

    return group
end

return ui_controls