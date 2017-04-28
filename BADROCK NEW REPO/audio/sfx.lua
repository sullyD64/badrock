local myData = require( "myData" )
local sfx = {}  --create the main Sound Effects (sfx) table.

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
