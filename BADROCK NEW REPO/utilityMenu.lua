local widget = require ("widget")
    
local utility = {}

-- -----------------------------------------------------------------------------------
-- ImageSheet per i bottoni (viola)
-- -----------------------------------------------------------------------------------

    local options =
        {
            frames =
            {
                {   -- frame 1 = UpperSX Corner
                    x = 0, y = 0, width = 20, height = 16 },
                {   -- frame 2 = Upper Side
                    x = 20, y = 0, width = 110 , height = 16 },
                {   -- frame 3 = UpperDX Corner 
                    x = 130, y = 0, width = 20, height = 16 },
                {   -- frame 4 = Left Side 
                    x = 0, y = 16, width = 20, height = 10 },
                {   -- frame 5 = LowerSX Corner 
                    x = 0, y = 26, width = 20, height = 24 },
                {   -- frame 6 = Lower Side 
                    x = 20, y = 26, width = 110, height = 24 },
                {   -- frame 7 = LowerDX Corner 
                    x = 130, y = 26, width = 20, height = 24 },
                {   -- frame 8 = Right Side 
                    x = 130, y = 16, width = 20, height = 10 },
                {   -- frame 9 = Center
                    x = 20, y = 16, width = 110, height = 10 },
                
                {   -- frame 10 = UpperSX Corner Over
                    x = 150, y = 0, width = 20, height = 16 },
                {   -- frame 11 = Upper Side Over
                    x = 166, y = 0, width = 110, height = 16 },
                {   -- frame 12 = UpperDX Corner Over
                    x = 280, y = 0, width = 20, height = 16 },
                {   -- frame 13 = SX Side Over
                    x = 150, y = 16, width = 20, height = 10 },
                {   -- frame 18 = Center Over
                    x = 166, y = 16, width = 110, height = 10 },
                {   -- frame 17 = DX Side Over
                    x = 280, y = 16, width = 20, height = 10 },
                {   -- frame 14 = LowerSX Corner Over 
                    x = 150, y = 23, width = 20 , height = 24 },
                {   -- frame 15 = Lower Side Over
                    x = 166, y = 23, width = 110, height = 24 },
                {   -- frame 16 = LowerDX Corner Over
                    x = 280, y = 23, width = 20, height = 24 }
            },
            sheetContentWidth = 300,
            sheetContentHeight = 46
        }
        
    utility.buttonSheet = graphics.newImageSheet( "misc/ButtonSpazi.png", options )
    
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
        else
            default_width = display.contentWidth * 0.33
            default_height = display.contentHeight
        end
     
        opt.width = customOptions.width or default_width
        opt.height = customOptions.height or default_height
     
        opt.speed = customOptions.speed or 500
        opt.inEasing = customOptions.inEasing or easing.linear
        opt.outEasing = customOptions.outEasing or easing.linear
     
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
        else
            container.anchorX = 0.5
            container.x = display.contentCenterX
            container.anchorY = 0.0
            container.y = display.actualContentHeight
        end
     
        function container:show()
            local options = {
                time = opt.speed,
                transition = opt.inEasing
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
            else
                options.x = display.actualContentWidth - opt.width
            end 
            transition.to( self, options )
        end
     
        function container:hide()
            local options = {
                time = opt.speed,
                transition = opt.outEasing
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
            else
                options.x = display.actualContentWidth
            end 
            transition.to( self, options )
        end
     
        return container
    end

return utility



