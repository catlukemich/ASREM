local gestures = {}

gestures.pinchListeners = {}

function gestures.enableMultitouchSimulation()
    gestures.enablePinch()

    local lastMouseEvent = nil

    local function onKeyEvent(event)
        if lastMouseEvent and event.keyName == "m" then
            lastMouseEvent.id = 1
            if event.phase == "down" then
                lastMouseEvent.phase = "began"
            elseif event.phase == "up" then
                lastMouseEvent.phase = "ended"
            end
            gestures.dispatchOnPinchEvent(lastMouseEvent)
        end
    end
    
    local function onMouseEvent(event)
        if event.type == "down" then
            event.phase = "began"
        elseif event.type == "move" or event.type == "drag" then
            event.phase = "moved"
        elseif event.type == "up" then
            event.phase = "ended"
        end

        if event.phase then
            lastMouseEvent = event
            event.id = 2
            gestures.dispatchOnPinchEvent(event)
        end
    end

    Runtime:addEventListener("mouse", onMouseEvent)
    Runtime:addEventListener("key", onKeyEvent )
end

function gestures.enablePinch()
    -- Detect if multitouch is supported and activate if so.
    if not system.hasEventSource("multitouch") then
        error("No multitouch supported") 
    else
        system.activate("multitouch")
    end
    Runtime:addEventListener("touch", gestures.onTouch)
end

function gestures.disablePinch()
    Runtime:removeEventListener("touch", gestures.onTouch)
end

function gestures.addPinchListener(pinchListenerFunction)
    local listenerObject = {listenerFunction = pinchListenerFunction}
    table.insert(gestures.pinchListeners, listenerObject)
end

function gestures.removePinchListener(pinchListenerFunction)
    -- TODO: Remove the listener somehow
    table.remove(gestures.pinchListeners, pinchListener)
 end

 function gestures.onTouch(event)
    gestures.dispatchOnPinchEvent(event)
 end

 function gestures.dispatchOnPinchEvent(event)
    for index, listenerObject in pairs(gestures.pinchListeners) do
        gestures.onPinch(listenerObject, event)
    end
 end

----------------------
-- BEGIN SAMPLE CODE
----------------------

function gestures.onPinch(listener, event)
    
    local function calculateDelta( previousTouches, event )
        local id, touch = next( previousTouches )
        if ( event.id == id ) then
            id, touch = next( previousTouches, id )
            assert( id ~= event.id )
        end
    
        local dx = touch.x - event.x
        local dy = touch.y - event.y
        return dx, dy
    end


    local result = true
	local phase = event.phase
	local previousTouches = listener.previousTouches
	local numTotalTouches = 1

	if previousTouches then
		-- Add in total from "previousTouches", subtracting 1 if event is already in the array
		numTotalTouches = numTotalTouches + listener.numPreviousTouches
		if previousTouches[event.id] then
			numTotalTouches = numTotalTouches - 1
		end
	end
	if ( "began" == phase ) then
		-- Set touch focus on first "began" event
		if not listener.isFocus then
			-- display.currentStage:setFocus( listener )
			listener.isFocus = true
			-- Reset "previousTouches"
			previousTouches = {}
			listener.previousTouches = previousTouches
			listener.numPreviousTouches = 0

		elseif not listener.distance then
			local dx, dy
			if previousTouches and ( numTotalTouches ) >= 2 then
				dx, dy = calculateDelta( previousTouches, event )
			end
			-- Initialize the distance between two touches
			if ( dx and dy ) then
				local d = math.sqrt( dx*dx + dy*dy )
				if ( d > 0 ) then
					listener.distance = d
					listener.xScaleOriginal = listener.xScale
					listener.yScaleOriginal = listener.yScale
				end
			end
		end

		if not previousTouches[event.id] then
			listener.numPreviousTouches = listener.numPreviousTouches + 1
		end
		previousTouches[event.id] = event

	-- If image is already in touch focus, handle other phases
	elseif listener.isFocus then
		-- Handle touch moved phase
		if ( "moved" == phase ) then
			if listener.distance then
				local dx, dy
				-- Must be at least 2 touches remaining to pinch/zoom
				if ( previousTouches and numTotalTouches >= 2 ) then
					dx, dy = calculateDelta( previousTouches, event )
				end

				if ( dx and dy ) then
					local newDistance = math.sqrt( dx*dx + dy*dy )
					local scale = newDistance / listener.distance
					if ( scale > 0 ) then
                        listener.listenerFunction(scale)
					end
				end
			end

			if not previousTouches[event.id] then
				listener.numPreviousTouches = listener.numPreviousTouches + 1
			end
			previousTouches[event.id] = event

		-- Handle touch ended and/or cancelled phases
		elseif ( "ended" == phase or "cancelled" == phase ) then
			if previousTouches[event.id] then
				listener.numPreviousTouches = listener.numPreviousTouches - 1
				previousTouches[event.id] = nil
			end

			if ( #previousTouches > 0 ) then
				listener.distance = nil
			else
				-- Since "previousTouches" is empty, no more fingers are touching the screen
				-- Thus, reset touch focus (remove from image)
				-- display.currentStage:setFocus( nil )
				listener.isFocus = false
				listener.distance = nil
				listener.xScaleOriginal = nil
				listener.yScaleOriginal = nil
				-- Reset array
				listener.previousTouches = nil
				listener.numPreviousTouches = nil
			end
		end
	end

	return result
end

return gestures