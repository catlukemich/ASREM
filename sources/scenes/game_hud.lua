local composer = require("composer");
local ui = require("sources.interface.ui");
local ui_controls = require("sources.interface.ui_controls")


local scene = composer.newScene();

function scene:create() 
    self.upgradeButton = ui_controls.createCostActionButton("upgrade_icon.png", 19, 24, "Upgrade", 1000)
    self.helipadButton = ui_controls.createCostActionButton("helipad_icon.png", 19, 24, "Helipad", 1000)
    self.cleanButton = ui_controls.createCostActionButton("clean_icon.png", 19, 24, "Clean", 1000)
    self.rentSlider = ui_controls.createLabeledSlider("Rent: $1000", 150, function(event) self:onRentSliderChange(event) end)
    self.speedControls = ui_controls.createSpeedControls(function(speed) self:onSpeedChange(speed) end)
    
    local leftControls = {self.upgradeButton, self.helipadButton, self.cleanButton, self.rentSlider, self.speedControls}
    ui.layoutElementsVertically(leftControls, {x = 0, y = display.contentHeight - 356, width = 0, height = 330})
    
    self.statusBar = ui_controls.createStatusBar()
    ui.alignBottom(self.statusBar)
    
    self.fundsGauge = ui_controls.createFundsGauge()
    self.fundsGauge:setFunds(4200)
    ui.alignBottom(self.fundsGauge)
    ui.alignRight(self.fundsGauge)
    
    self.conentmentDisplay = ui_controls.createContentmentDisplay()
    self.conentmentDisplay.y = display.contentHeight - 140
    ui.alignRight(self.conentmentDisplay)
    
    self.dateDisplay = ui_controls.createDateDisplay()
    self.dateDisplay.y = display.contentHeight - 70
    self.dateDisplay:setDate(12,3)
    ui.alignRight(self.dateDisplay)
end

function scene:show(event)
    self.gameScene = event.parent
end

function scene:onRentSliderChange(event)
    local percentage = self.rentSlider:getValue()
    local rent = percentage / 100 * 2000
    self.rentSlider:setLabel("Rent: $" .. tostring(rent))
end

function scene:onSpeedChange(speed) 
    self.gameScene:setSpeed(speed)
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