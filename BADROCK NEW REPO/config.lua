--
-- For more information on config.lua see the Corona SDK Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--



local aspectRatio = display.pixelHeight / display.pixelWidth
application = {
   content = {
      --width = aspectRatio > 1.5 and 720 or math.ceil( 1080 / aspectRatio ),
      --height = aspectRatio < 1.5 and 1080 or math.ceil( 720 * aspectRatio ),
      width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
      height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
      scale = "zoomEven",
      fps=60,

      imageSuffix = {
         ["@2"] = 1.8,
         ["@4"] = 3.6,
      },
   },
}

--application =
--{
	--content =
	--{
		  --width = 320,
		  --height = 480, 
		--width = 720,
		--height = 1080, 
		--scale = "zoomEven",
		--fps = 60,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	--},
--} 
