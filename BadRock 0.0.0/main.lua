<<<<<<< HEAD
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
composer.gotoScene( "menu" ) --PROVVISORIA
=======
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
audio.setVolume( 0.4, { channel=1 } )


-- load menu screen
composer.gotoScene( "level1" ) --PROVVISORIA
>>>>>>> 73c6b80ff362233fa5d3b35497b4ac58c1f525b1
