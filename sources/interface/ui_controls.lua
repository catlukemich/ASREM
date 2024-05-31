local widget = require("widget");
local ui = require("sources.interface.ui");

local ui_controls = {};

-- iconFilename - the file name of an icon file located in "assets/ui/actions/" directory
function ui_controls.createCostActionButton(iconFilename, width, height, label, cost, listener)
    local group = display.newGroup();
    
    
    local fontName = "assets/fonts/Teko-Bold.ttf";
    local fontSize = 20
    local buttonLabel = display.newText(label, 0, 0, fontName, fontSize);
    buttonLabel.x = 45
    buttonLabel.y = -10

    local filePath = "assets/ui/actions/" .. iconFilename;
    local buttonIcon = display.newImageRect(filePath, width, height);
    buttonIcon.x = 116
    buttonIcon.y = -10

    fontName = "assets/fonts/Teko-Regular.ttf";
    fontSize = 16
    local costLabel  = display.newText("$" .. tostring(cost), 0, 0, fontName, fontSize);
    costLabel:setFillColor(1,1,1);
    costLabel.x = 45
    costLabel.y = 15

    local buttonBackground = ui.createImageButton("assets/ui/actions/action_button_background.png", 140, 48, listener);
    buttonBackground.x = 70
    buttonBackground.y = -10
    local costBackground = display.newImageRect("assets/ui/actions/action_cost_background.png", 112, 22)
    costBackground.x = 56
    costBackground.y = 14

    group:insert(costBackground)
    group:insert(buttonBackground);
    group:insert(buttonLabel)
    group:insert(buttonIcon)
    group:insert(costLabel)

    function group:setCost(cost)
        costLabel.text = "$" .. tostring(cost)
    end

    return group
end

function ui_controls.createSpeedControls(speedChangeListener)
    local function createSingleButton(imagePath, width, height)
        local group = display.newGroup()

        local backgroundButton = ui.createImageButton("assets/ui/speed_chooser/background_button.png", width, height)
        local buttonImage = display.newImageRect(imagePath, width, height);

        group:insert(backgroundButton)
        group:insert(buttonImage)

        function group:addEventListener(type, listener)
            backgroundButton:addEventListener(type, listener)
        end

        return group
    end

    local group = display.newGroup()

    local pauseButton = createSingleButton("assets/ui/speed_chooser/paused.png", 40, 40)
    local normalSpeedButton = createSingleButton("assets/ui/speed_chooser/normal.png", 40, 40)
    local speed2xButton = createSingleButton("assets/ui/speed_chooser/speed2x.png", 60, 40)
    local speed4xButton = createSingleButton("assets/ui/speed_chooser/speed4x.png", 60, 40)
    local endingGradient = display.newImageRect("assets/ui/speed_chooser/end_gradient.png", 55, 40);
    
    pauseButton.speed = 0
    normalSpeedButton.speed = 1
    speed2xButton.speed = 2
    speed4xButton.speed = 4

    local selectedRect = display.newRect(0, 0, 40,40);
    selectedRect:setFillColor(255/255, 195/255, 0)
    normalSpeedButton:insert(2, selectedRect)

    ui.layoutElementsHorizontally(
        {pauseButton, normalSpeedButton, speed2xButton, speed4xButton, endingGradient}, 
        {x = 0, y = 0, width = 263, height = 0}
    )

    group:insert(pauseButton)
    group:insert(normalSpeedButton)
    group:insert(speed2xButton)
    group:insert(speed4xButton)
    group:insert(endingGradient)
    
    local function buttonTap(button)
        selectedRect.width = button.width
        selectedRect.height = button.height
        button:insert(2, selectedRect);
        if (speedChangeListener ~= nil) then 
            speedChangeListener(button.speed)
        end 
    end

    pauseButton:addEventListener("tap", function() buttonTap(pauseButton) end)
    normalSpeedButton:addEventListener("tap", function() buttonTap(normalSpeedButton) end)
    speed2xButton:addEventListener("tap", function() buttonTap(speed2xButton) end)
    speed4xButton:addEventListener("tap", function() buttonTap(speed4xButton) end)

    return group
end

function ui_controls.createLabeledSlider(label, width, listener)
    local group = display.newGroup();

    local background = display.newImageRect("assets/ui/slider/slider_background.png", width + 80, 40)
    background.x = (width + 80) / 2
    group:insert(background)

    local sheetOptions = {
        width = 10,
        height = 24,
        numFrames = 5,
        sheetContentWidth = 50,
        sheetContentHeight = 24
    }

    local sheet = graphics.newImageSheet("assets/ui/slider/slider_sheet.png", sheetOptions)
    
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
    local background = display.newImageRect("assets/ui/statusbar/background.png", width, 26);
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
    label:setFillColor(1,1,1);

    local chartButton = ui.createImageButton("assets/ui/funds_gauge/chart_button.png", 24, 24, chartButtonListener)
    chartButton.x = 68
    chartButton.y = 0

    local background = display.newImageRect("assets/ui/funds_gauge/background.png", 196, 30);
    

    group:insert(background)
    group:insert(chartButton)
    group:insert(label)

    function group:setFunds(funds)
          label.text = "Funds: $" .. tostring(funds)
    end

    return group
end


function ui_controls.createContentmentDisplay()
    local group = display.newGroup();
   
    local fontName = "assets/fonts/Teko-Regular.ttf"
    local fontSize = 18
    local label = display.newText("Contentment", 0, 0, fontName, fontSize)
    label.x = 10
    label.y = -16
    
    local emoticon = display.newImage("assets/ui/contentment/happy.png",24,24);
    emoticon.x = 10
    emoticon.y = 10

    local background = display.newImageRect("assets/ui/contentment/background.png", 110, 60 )

    group:insert(background)
    group:insert(emoticon)
    group:insert(label)

    function group:setContentment(contentment)
        local dirPath = "assets/ui/contentment/"
        local emoticonFilename = {
            "very_unhappy.png", "unhappy.png", "indifferent.png", "happy.png"
        }
        local fullPath = dirPath .. emoticonFilename[contentment]
        local newEmoticon = display.newImageRect(fullPath, 24, 24)

        group:insert(newEmoticon)
        newEmoticon.x = emoticon.x
        newEmoticon.y = emoticon.y
        emoticon:removeSelf();
    end

    return group

end


function ui_controls.createDateDisplay()
    local group = display.newGroup();
    
    local fontName = "assets/fonts/Teko-Regular.ttf"
    
    local fontSize = 20
    local labelMonth = display.newText("Month: 1", 0, 0, fontName, fontSize)
    labelMonth.x = 10
    labelMonth.y = -10
    
    fontSize = 16
    local labelDay = display.newText("Day: 1", 0, 0, fontName, fontSize)
    labelDay.x = 10
    labelDay.y = 14

    local background = display.newImageRect("assets/ui/date/background.png", 110, 60)

    group:insert(background)
    group:insert(labelMonth)
    group:insert(labelDay)

    function group:setMonth(month)
        labelMonth.text = "Month: " .. tostring(month)
    end

    function group:setDay(day)
        labelDay.text = "Month: " .. tostring(day)
    end

    function group:setDate(month, day)
        self:setMonth(month)
        self:setDay(day)
    end

    return group
end

return ui_controls