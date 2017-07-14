local myData = require( "myData" )
--create the main Sound Effects (sfx) table.
local sfx = { 
  bgMenuMusic  = audio.loadStream( "audio/overside8bit.wav" ),
  bgLvlMusic   = audio.loadStream( "audio/Level1BGM/Highways_standard.mp3" ),
  bgLvlMusicUP = audio.loadStream( "audio/Level1BGM/Highways_G_faster.mp3" ),
  jumpSound     = audio.loadSound( "audio/jump.wav"       ),
  coinSound     = audio.loadSound( "audio/coin.wav"       ),
  lifeupSound   = audio.loadSound( "audio/lifeup.wav"     ),
  gunSound      = audio.loadSound( "audio/gun.wav"        ),
  boom1Sound    = audio.loadSound( "audio/boom_small.wav" ),
  boom2Sound    = audio.loadSound( "audio/boom_big.wav"   ),
  noAmmoSound   = audio.loadSound( "audio/noAmmo.wav"     ),
  attackSound   = audio.loadSound( "audio/attack.wav"     ),
  dangerSound   = audio.loadSound( "audio/danger3.wav"    ),
  enemyDefSound = audio.loadSound( "audio/enemyDef.wav"   ),
  npcGoodSound  = audio.loadSound( "audio/npc_good.wav"   ),
  npcEvilSound  = audio.loadSound( "audio/npc_evil.wav"   ),
  levelEndSound = audio.loadSound( "audio/level_ended.wav"),
  gameOverSound = audio.loadSound( "audio/game_over.wav"  ),
  buttonSound = audio.loadSound( "audio/buttonPress.wav"  ),
}

-- inizializzare i volumi e i canali dei diversi suoni
sfx.init = function()
	-- riserva 5 canali audio
   audio.reserveChannels(9)
   --sfx.masterVolume = audio.getVolume()  --print( "volume "..masterVolume )
   audio.setVolume( 0.40, { channel = 1 } )  --background music
   audio.setVolume( 0.66, { channel = 2 } )  --jump sound
   audio.setVolume( 1.0,  { channel = 3 } )  --coin sound
   audio.setVolume( 1.0,  { channel = 4 } )  --attack sound
   audio.setVolume( 0.50, { channel = 5 } )  --danger sound
   audio.setVolume( 0.8,  { channel = 6 } )  --boom sounds
   audio.setVolume( 2.80, { channel = 7 } )  --louder sounds
   audio.setVolume( 0,    { channel = 8 } )  --powerup music
   audio.setVolume( 1,  { channel = 9 } )  -- button sounds
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
    audio.setVolume( 0, { channel=6 } )
    audio.setVolume( 0, { channel=7 } )
    audio.setVolume( 0, { channel=9 } )
end


sfx.setVolumeSound = function(level)
    audio.setVolume( level, { channel=2 } )
    audio.setVolume( level, { channel=3 } )
    audio.setVolume( level, { channel=4 } )
    audio.setVolume( level, { channel=5 } )
    audio.setVolume( level, { channel=6 } )
    audio.setVolume( level, { channel=7 } )
    audio.setVolume( level, { channel=9 } )
end

sfx.toggleAlternativeBgm = function( flag )
  if (flag == "on") then
    sfx.altBgmIsPlaying = true
    audio.setVolume( audio.getVolume({channel=1}), {channel = 8} )
    audio.setVolume( 0, {channel = 1} )
  elseif (flag == "off") then
    sfx.altBgmIsPlaying = false
    audio.setVolume( audio.getVolume({channel=8}), {channel = 1} )
    audio.setVolume( 0, {channel = 8} )
  end
end

-- sfx.pauseMusic = function(channel)
-- 	if ( myData.settings.musicOn == true ) then
--       -- ^ Le opzioni ci dicono di non riprodurre suoni
--       return false
--    end
--    audio.pause(channel)
-- end

return sfx
