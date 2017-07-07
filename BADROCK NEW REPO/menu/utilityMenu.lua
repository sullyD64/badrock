-----------------------------------------------------------------------------------------
--
-- utilityMenu.lua
--
-- This includes a sligthly modified version of the "SlidingPanel" class.
-- This allows to specify the widget coordinates as well as the anchor points,
-- plus, a "static" position can be declared which will override the show() and hide()
-- methods to perform a simple alpha channel fade in-out of the display objects contained
-- in the panel.
-----------------------------------------------------------------------------------------

local widget = require ("widget")


local utility = {}

utility.font = "Berlin Sans FB Regular.ttf"--"ITCKRIST.TTF"--"Micolas.ttf"

-- -----------------------------------------------------------------------------------
-- ImageSheets
-- -----------------------------------------------------------------------------------

	-- volume slider sheet
	local sliderOptions = {
		frames = {
			{ x=0, y=0, width=14, height=21 },
			{ x=17, y=0, width=16, height=21 },
			{ x=34, y=0, width=16, height=21 },
			{ x=52, y=0, width=18, height=21 },
			{ x=78, y=0, width=30, height=21 }
			},
		sheetContentWidth = 109,
		sheetContentHeight = 21
		}
	utility.sliderSheet = graphics.newImageSheet( visual.sliderSheet, sliderOptions )

	-- checkbox sheet
	local checkboxOptions = {
			width = 21,
			height = 21,
			numFrames = 2,
			sheetContentWidth = 42,
			sheetContentHeight = 21
		}
	utility.checkboxSheet = graphics.newImageSheet( visual.checkboxSheet, checkboxOptions )


-- -----------------------------------------------------------------------------------
-- Creazione dei pannelli a scorrimento
-- -----------------------------------------------------------------------------------

	function utility.newPanel( options )
	local customOptions = options or {}
	local opt = {}

	opt.location = customOptions.location or "top"

	local default_width, default_height
	if ( opt.location == "top" or opt.location == "bottom" ) then
		default_width = display.contentWidth
		default_height = display.contentHeight * 0.33
	elseif ( opt.location == "left" or opt.location == "right" ) then
		default_width = display.contentWidth * 0.33
		default_height = display.contentHeight
	else
		default_width = display.contentWidth
		default_height = display.contentHeight
	end

	opt.width = customOptions.width or default_width
	opt.height = customOptions.height or default_height

	opt.speed = customOptions.speed or 500
	opt.inEasing = customOptions.inEasing or easing.linear
	opt.outEasing = customOptions.outEasing or easing.linear

	-------------------------------------------------
	opt.anchorX = customOptions.anchorX or 0.5
	opt.anchorY = customOptions.anchorY or 0.5
	opt.x = customOptions.x or display.contentCenterX
	opt.y = customOptions.y or display.contentCenterY
	-------------------------------------------------

	if ( customOptions.onComplete and type(customOptions.onComplete) == "function" ) then
		opt.listener = customOptions.onComplete
	else 
		opt.listener = nil
	end

	local container = display.newContainer( opt.width, opt.height )

	if ( opt.location == "left" ) then
		container.anchorX = 1.0
		container.x = display.screenOriginX
		container.anchorY = 0.5
		container.y = display.contentCenterY
	elseif ( opt.location == "right" ) then
		container.anchorX = 0.0
		container.x = display.actualContentWidth
		container.anchorY = 0.5
		container.y = display.contentCenterY
	elseif ( opt.location == "top" ) then
		container.anchorX = 0.5
		container.x = display.contentCenterX
		container.anchorY = 1.0
		container.y = display.screenOriginY
	elseif ( opt.location == "bottom" ) then
		container.anchorX = 0.5
		container.x = display.contentCenterX
		container.anchorY = 0
		container.y = display.actualContentHeight
	elseif ( opt.location == "custom" ) then
		container.anchorX = opt.anchorX
		container.anchorY = opt.anchorY
		container.x = opt.x
		container.y = opt.y
	elseif ( opt.location == "static") then
		container.anchorX = opt.anchorX
		container.anchorY = opt.anchorY
		container.x = opt.x
		container.y = opt.y
	else
		container.x = display.contentCenterX
		container.y = display.contentCenterY
	end

	function container:show(tab)
		local tab = tab or {}
		local options = {
			time = tab.speed or opt.speed,
			transition = tab.transition or opt.inEasing,
			x = tab.x or opt.x,
			y= tab.y or opt.y
		}
		if ( opt.listener ) then
			options.onComplete = opt.listener
			self.completeState = "shown"
		end
		if ( opt.location == "top" ) then
			options.y = display.screenOriginY + opt.height
		elseif ( opt.location == "bottom" ) then
			options.y = display.actualContentHeight - opt.height
		elseif ( opt.location == "left" ) then
			options.x = display.screenOriginX + opt.width
		elseif ( opt.location == "right" ) then
			options.x = display.actualContentWidth - opt.width
		-- elseif (opt.location == "custom") then
		--     options.y = display.screenOriginY + opt.height
		elseif ( opt.location == "static" ) then
			options.alpha = 1
		end
		transition.to( self, options )
	end

	function container:hide(tab)
		local tab = tab or {}
		local options = {
			time = tab.speed or opt.speed,
			transition = tab.transition or opt.outEasing,
			--alpha = tab.alpha,
			x = tab.x or opt.x,
			y= tab.y or opt.y
		}
		if ( opt.listener ) then
			options.onComplete = opt.listener
			self.completeState = "hidden"
		end
		if ( opt.location == "top" ) then
			options.y = display.screenOriginY
		elseif ( opt.location == "bottom" ) then
			options.y = display.actualContentHeight
		elseif ( opt.location == "left" ) then
			options.x = display.screenOriginX
		elseif ( opt.location == "right" ) then
			options.x = display.actualContentWidth
		elseif (opt.location == "custom") then
			options.y = opt.x
			options.y = opt.y
			
		elseif ( opt.location == "static" ) then
			options.alpha = 0
		end
		transition.to( self, options )
	end

	return container
end



return utility



