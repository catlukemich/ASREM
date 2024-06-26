local json = require("json")
local mathutils = require("sources.mathutils")
local iso_sprite = require("sources.iso.iso_sprite")

local iso_curve = {}

--- Parse curves from a file containing curves data
-- @param filePath - the path to the file in the resources directory to use for parsing
-- @param join - whether to join the parsed curves together (join their ends and beginnings) - defaults to true
function iso_curve.parseCurves(filePath, join)
    if join ~= false then join = true end
    local path = system.pathForFile(filePath)
    local decodedJSON = json.decodeFile(path)
    local beziers = {}
    if decodedJSON == nil then
        error("Can't parse iso_curve file: " .. filePath)
    end
    for _, curveData in pairs(decodedJSON) do
        local cp1 = curveData.cp1
        if cp1 == nil then
            error("cant' parse!")
        end
        local cp2 = curveData.cp2
        local cp3 = curveData.cp3
        local cp4 = curveData.cp4
        local bezier = mathutils.CubicBezier:new(cp1, cp2, cp3, cp4)
        iso_curve.applyConnectionProperties(bezier)
        table.insert(beziers, bezier)
    end

    if join then
        for _, curve1 in ipairs(beziers) do
            for _, curve2 in ipairs(beziers) do
                curve1:connectTo(curve2)
            end    
        end
    end

    return beziers
end



function iso_curve.applyConnectionProperties(curve)
    curve.incomingConnections = {}
    curve.outcomingConnections = {}

    function curve:connectTo(otherCurve)
        -- @type Vector3d
        local selfStartLocation = curve:interpolate(0)
        local selfEndLocation = curve:interpolate(1)

        local otherStartLocation = otherCurve:interpolate(0)       
        local otherEndLocation = otherCurve:interpolate(1)       

        -- Try to join only start with end because it doesn't make sens to do otherwise
        if selfStartLocation:isNear(otherEndLocation, 0.01) then
            -- Join other end to this start.
            table.insert(self.incomingConnections, otherCurve)
        elseif selfEndLocation:isNear(otherStartLocation, 0.01) then
            -- Join this end to other start
            table.insert(self.outcomingConnections, otherCurve)
        end
    end
      
end

---Create an isometric curve that can be displayed on the screen:
---@param bezier  iso_curve.Bezier Bezier curve used for the display curve
---@param isoView iso_view.IsoView Isometric view used for the displaying of the curve
---@param segments number Number of segments of the curve (this curve isn't strictly a curve - it's a collection of lines)
---@param markDirection boolean A flag indicating whether to use start and end markings (the start will be marked by a rectange, the end - by circle) - defaults to nil
function iso_curve.newDisplayCurve(bezier, isoView, segments, markDirection)
    local group = display.newGroup()
    iso_sprite.applyIsometricProperties(group)
    
    local colorStart = {1, 1, 0}
    local colorEnd = {0, 0, 1}

    local segments = segments or 10
    for segment = 0, segments - 1 do
        local t1 = segment / segments
        local t2 = (segment + 1) / segments

        local loc1 = bezier:interpolate(t1)
        local loc2 = bezier:interpolate(t2)

        local x1, y1 = isoView:project(loc1, isoView.isoGroup)
        local x2, y2 = isoView:project(loc2, isoView.isoGroup)

        
        local line = display.newLine(x1, y1, x2, y2)
        group:insert(line)

        local color = {
            (1 - ((t1 + t2) / 2)) * colorStart[1] + ((t1 + t2) / 2) * colorEnd[1], 
            (1 - ((t1 + t2) / 2)) * colorStart[2] + ((t1 + t2) / 2) * colorEnd[2], 
            (1 - ((t1 + t2) / 2)) * colorStart[3] + ((t1 + t2) / 2) * colorEnd[3], 
        }
        line:setStrokeColor(color[1], color[2], color[3])
    end
    
    if markDirection then
        local startLoc = bezier:interpolate(0)
        local endLoc = bezier:interpolate(1)

        local xStart, yStart = isoView:project(startLoc, isoView.isoGroup)
        local xEnd, yEnd = isoView:project(endLoc, isoView.isoGroup)
        
        local startMark = display.newRect(xStart - 2, yStart - 2, 8, 8)
        startMark:setFillColor(1, 1, 0)
        group:insert(startMark)

        local endMark = display.newCircle(xEnd, yEnd, 5)
        endMark:setFillColor(0, 0, 1)
        group:insert(endMark)
    end

    return group
end

function iso_curve.makeCurveTraveler(isoSprite)
    local traveler = isoSprite

    traveler.curve = nil
    traveler.t = 0

    function traveler:setCurve(curve) 
        traveler.curve = curve
        traveler.t = 0
    end

    function traveler:setStep(distance)
        traveler.step = distance
    end

    ---Update the traveler self traveling logic.
    ---@param time number Time in miliseconds indicating the elapsed time since last frame.
    ---@param travelDistance number The distance that we want to travel, 0.01 by default 
    ---@return number The angle on the z axis that the traveling object is rotated at the new point.
    function traveler:updateTraveler(time, travelDistance)
        travelDistance = travelDistance or 0.21
        travelDistance = travelDistance * time
        local previousLocation = traveler.curve:interpolate(traveler.t)
        local newLocation = nil
        local leftoverT = 0
        local currentT = traveler.t
        local curveStretchFactor = 1 / (self.curve:interpolate(0):distance(self.curve:interpolate(1)) * 3)
        for i = 0,50 do
            currentT = currentT + (travelDistance / 3) * curveStretchFactor
            local candidateLocation = traveler.curve:interpolate(currentT)
            local distanceToCandidateLocation = previousLocation:distance(candidateLocation)
            if distanceToCandidateLocation > travelDistance then
                local toVector = previousLocation:to(candidateLocation)
                toVector:normalize()
                toVector:multSelf(travelDistance)
                newLocation = previousLocation:add(toVector)
                if currentT > 1 then
                    leftoverT = currentT - 1
                end
                traveler.t = currentT
                didBreak = true
                break
            end

            local toVector = previousLocation:to(candidateLocation)
            toVector:normalize()
            toVector:multSelf(travelDistance)
            newLocation = previousLocation:add(toVector)
            if currentT > 1 then
                leftoverT = currentT - 1
                traveler.t = currentT   
                break
            end
            traveler.t = currentT            
        end


        traveler:setLocation(newLocation)
        if traveler.t >= 1 then
            local connections = traveler.curve.outcomingConnections
            if #connections > 0 then
                local randomCurve = connections[math.random(#connections)]
                traveler:setCurve(randomCurve)
            end
            traveler.t = leftoverT
        end

        local xForward = mathutils.Vector3:new(1,0,0)
        local toVector = mathutils.Vector3:new(newLocation.x - previousLocation.x, newLocation.y - previousLocation.y, 0)
        local atan = math.atan(toVector.y / toVector.x)
        local dot = xForward:dot(toVector)
        local degs = math.deg(atan)
        if dot < 0 then
            degs = 180 + degs
        end
        if(degs < 0)then
            degs = 360 + degs
        end
        return degs
    end

    function traveler:update(time)
        traveler:updateTraveler(time)
    end

    return traveler
end

return iso_curve