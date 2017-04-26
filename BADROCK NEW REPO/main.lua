-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local sfx = require( "sfx" )					--HERE
sfx.init()
-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Include the Corona "composer" module
local composer = require "composer"

-- Enable the multitouch 
system.activate( "multitouch" )


-- -- Reserve channel 1 and 2 for background music and sound effect
-- audio.reserveChannels(2)
-- -- Reduce the overall volume of the channel
-- audio.setVolume( 0, { channel=1 } )

-- load menu screen
composer.gotoScene( "menu" )






