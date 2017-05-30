-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Global imports
local composer = require ( "composer"      )
visual         = require ( "visual.visual" ) 
filters        = require ( "lib.filters"   )
util           = require ( "lib.util"      )

local sfx = require( "audio.sfx" )
sfx.init()

-- Enable the multitouch 
system.activate( "multitouch" )

display.setDefault( "minTextureFilter", "nearest" )
--display.setDefault( "magTextureFilter", "nearest" )


-- load menu screen
-- composer.gotoScene( "menu.mainMenu" )
composer.gotoScene( "levels.level1" )


