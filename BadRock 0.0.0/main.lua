-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Include the Corona "composer" module
local composer = require "composer"

-- Enable the multitouch 
system.activate( "multitouch" )

-- Reserve channel 1 for background music
audio.reserveChannels( 1 )
-- Reduce the overall volume of the channel
audio.setVolume( 0.5, { channel=1 } )


-- load menu screen
composer.gotoScene( "level1" ) --PROVVISORIA