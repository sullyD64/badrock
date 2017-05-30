-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Include the Corona "composer" module
local composer = require "composer"

-- Load the audio module for initialization
local sfx = require( "audio.sfx" )
sfx.init()

-- Globally loads the visual library
visual = require "visual.visual"

util = require "lib.util"

-- Enable the multitouch 
system.activate( "multitouch" )

display.setDefault( "minTextureFilter", "nearest" )
--display.setDefault( "magTextureFilter", "nearest" )


-- load menu screen
-- composer.gotoScene( "menu.mainMenu" )
composer.gotoScene( "levels.level1" )


