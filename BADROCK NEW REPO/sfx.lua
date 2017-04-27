local myData = require( "myData" )
local sfx = {}  --create the main Sound Effects (sfx) table.

--TO DO (futuro) AUDIO
--In pausa abbassare il volume


sfx.bgMenuMusic = audio.loadStream( "audio/Undertale - Bonetrousle.mp3" )     --(ovviamente cambiare il brano)
sfx.bgLvlMusic= audio.loadStream("audio/overside8bit.wav")
sfx.jumpSound = audio.loadSound("audio/jump.wav")
sfx.coinSound = audio.loadSound("audio/coin.wav")
sfx.attackSound = audio.loadSound( "audio/attack.wav")
sfx.dangerSound = audio.loadSound( "audio/danger3.wav")

-- inizializzare i volumi e i canali dei diversi suoni
sfx.init = function()
	-- riserva 5 canali audio
   audio.reserveChannels(5)
   --sfx.masterVolume = audio.getVolume()  --print( "volume "..masterVolume )
   audio.setVolume( 0.40, { channel = 1 } )  --background music
   audio.setVolume( 0.66, { channel = 2 } )  --jump sound
   audio.setVolume( 1.0,  { channel = 3 } )  --coin sound
   audio.setVolume( 1.0,  { channel = 4 } )  --attack sound
   audio.setVolume( 0.25, { channel = 5 } )  --danger sound
end

sfx.playSound = function( handle, options )
   if ( myData.settings and myData.settings.soundOn == false ) then
      -- ^ Le opzioni ci dicono di non riprodurre suoni
      return false
   end

   audio.play( handle, options )
end

sfx.playMusic = function( handle, options )
   if ( myData.settings and myData.settings.musicOn == false ) then
      -- ^ Le opzioni ci dicono di non riprodurre suoni
      return false
   end
   audio.rewind(handle)
   audio.play( handle, options )
end


sfx.pauseSound = function()
 	audio.setVolume( 0, { channel=2 } )
    audio.setVolume( 0, { channel=3 } )
    audio.setVolume( 0, { channel=4 } )
    audio.setVolume( 0, { channel=5 } )
end


sfx.setVolumeSound = function(level)
    audio.setVolume( level, { channel=2 } )
    audio.setVolume( level, { channel=3 } )
    audio.setVolume( level, { channel=4 } )
    audio.setVolume( level, { channel=5 } )
end

-- sfx.pauseMusic = function(channel)
-- 	if ( myData.settings.musicOn == true ) then
--       -- ^ Le opzioni ci dicono di non riprodurre suoni
--       return false
--    end
--    audio.pause(channel)
-- end


return sfx
-- -- -----------------------------------------------------------------------------------------------

-- -- Given that the enterScene and exitScene events happen in pairs, enterScene is probably the best place to load scene-specific 
-- -- sounds. You can then dispose of them using audio.dispose() in the exitScene event (don’t forget to nil out the handle!).
-- -- But wait… what if your sound is still playing (and can’t just be abruptly stopped) when your app tries to go to a new scene? 
-- -- In the next scene, you no longer have access to the audio handle, so proper cleanup and disposal is tricky. Fortunately, this 
-- -- can be solved by loading the sound into the sfx table and using an anonymous function to dispose it on the onComplete phase. 
-- -- Consider this code:

-- local sfx = require( "sfx" )
 
-- -- forward declare the handle
-- sfx.longsound = nil
 
-- function scene:createScene( event )
--    local group = self.view

 
--    local function leaveScene(event)
--       if ( event.phase == "ended" ) then
--          storyboard.gotoScene( "b" )
--       end
--    end
 
--    local button = display.newRect( 100,100,100,100 )
--    group:insert( button )
--    button:addEventListener( "touch", leaveScene )
 
-- end
 
-- function scene:enterScene( event )
--     sfx.longsound = audio.loadSound("audio/mirv_missiles_online.wav")
-- 	audio.play( sfx.longsound, { onComplete = function()
-- 												audio.dispose( sfx.longsound )
--                                       			end } )


-- Since Lua lets you write “anonymous functions” that onComplete events can call, 
-- you can use this method to dispose of an audio file after it’s finished. 
-- Notice that we still need to forward-declare the sound handle in the sfx table 
-- before it actually gets used.





-- ALTRI APPUNTI
-- The way I do it is I have a flag like:
 
-- local mySettings = {}
-- mySettings.soundOn = true
 
-- then if they tap a button to turn off sound, I change the flag to false:
 
-- mySettings.soundOn = false
 
-- Then every where I play a sound I wrap it in an "if" statement:
 
-- if mySettings.soundOn then
--     audio.play(mysound)
-- end
 
-- Now I put the setting in a table of all my settings for easy saving/loading of the settings data between sessions. 
-- You can also do things like:
 
-- mySettings.musicOn = true
 
-- and use the same thing to separate your background music from your sound effects.





-- APPUNTI ALTRO MODO AUDIO MANAGEMENT
-- Main.lua

-- bgMusicChannel = 1 -- can be 1-32
-- bgMusic = audio.loadSound( "sounds/Torukia.mp3" )
-- musicIsPlaying = false
-- mainMenu.lua

-- if musicIsPlaying == false then
--         if gameSettings.soundOn == true then
--             backgroundMusicChannel = audio.play( bgMusic, { loops=-1,channel = bgMusicChannel } )
--             musicIsPlaying = true
--         elseif gameSettings.soundOff == true then
--             musicIsPlaying = false
--         end
--     end
-- end
-- optionsMenu.lua

-- local function toggleSound( event )
--     if event.phase == "ended" then
--         if gameSettings.soundOn == true then
--             gameSettings.soundOn = false
--             gameSettings.soundOff = true
--             audio.stop( bgMusicChannel )
--     soundBtn:setFillColor( 255,0,0 )
--         elseif gameSettings.soundOff == true then
--             gameSettings.soundOn = true
--             gameSettings.soundOff = false
--             backgroundMusicChannel = audio.play( bgMusic, { loops=-1, channel = bgMusicChannel } )
--     soundBtn:setFillColor( 0,255,0 )
--         end
--         saveSettings(gameSettings, "gameSettings.json")
--     end
-- end