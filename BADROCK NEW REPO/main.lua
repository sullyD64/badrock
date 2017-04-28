-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Include the Corona "composer" module
local composer = require "composer"
local sfx = require( "audio.sfx" )

-- Globally loads the visual library
visual = require "visual.visual"

-- Enable the multitouch 
system.activate( "multitouch" )

sfx.init()

-- load menu screen
composer.gotoScene( "menu.mainMenu" )
--composer.gotoScene( "levels.level1" )
