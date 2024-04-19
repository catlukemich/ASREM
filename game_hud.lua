local ui = require("ui");
local ui_controls = require("ui_controls")
local composer = require("composer");

local scene = composer.newScene();


function scene:create() 

end

function scene:show()
    -- self.upgradeButton = ui.createImageButton("assets/graphics/ui/upgrade_button.png", 160, 50)
    self.upgradeButton = ui_controls.createCostActionButton("upgrade_icon.png", 19, 24, "Upgrade", 1000)
    self.helipadButton = ui_controls.createCostActionButton("helipad_icon.png", 19, 24, "Helipad", 1000)
    self.helipadButton.y = 100
    self.cleanButton = ui_controls.createCostActionButton("clean_icon.png", 19, 24, "Clean", 1000)
    self.cleanButton.y = 200
    self.upgradeButton:setCost(1000)

    self.rentSlider = ui_controls.createLabeledSlider("Rent: $1000", 150, function(event) self:onRentSliderChange(event) end)
    -- self.rentSlider:setLabel("Hello")
    self.rentSlider.x = 0
    self.rentSlider.y = display.contentHeight - 70

    local actionButtons = {self.upgradeButton, self.helipadButton, self.cleanButton}

    ui.layoutElementsVertically(actionButtons, {x = 0, y = display.contentHeight - 380, width = 0, height = 250})

    self.statusBar = ui_controls.createStatusBar()
    ui.alignBottom(self.statusBar)

    self.fundsGauge = ui_controls.createFundsGauge()
    
    ui.alignBottom(self.fundsGauge)
    ui.alignRight(self.fundsGauge)
end

function scene:onRentSliderChange(event)
    local percentage = self.rentSlider.getValue()
    local rent = percentage / 100 * 2000
    self.rentSlider:setLabel("Rent: $" .. tostring(rent))
end

function scene:hide()
end

function scene:destroy()
end

scene:addEventListener("create" , scene )
scene:addEventListener("show"   , scene )
scene:addEventListener("hide"   , scene )
scene:addEventListener("destroy", scene )

return scene