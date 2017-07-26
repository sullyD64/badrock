-- local myData = require( "myData" )
--create the main Sound Effects (sfx) table.
local sfx = { 
  bgMenuMusic  = audio.loadStream( "audio/overside8bit.mp3" ),
  bgLvlMusic   = audio.loadStream( "audio/Level1BGM/Highways_standard.mp3" ),
  bgLvlMusicUP = audio.loadStream( "audio/Level1BGM/Highways_G_faster.mp3" ),
  bgBossMusic  = audio.loadStream( "audio/Level1BGM/Highways_shuffle_fastest.mp3"),
  jumpSound     = audio.loadSound( "audio/jump.wav"       ),
  coinSound     = audio.loadSound( "audio/coin.wav"       ),
  lifeupSound   = audio.loadSound( "audio/lifeup.wav"     ),
  gunSound      = audio.loadSound( "audio/gun.wav"        ),
  boom1Sound    = audio.loadSound( "audio/boom_small.wav" ),
  boom2Sound    = audio.loadSound( "audio/boom_big.wav"   ),
  noAmmoSound   = audio.loadSound( "audio/noAmmo.wav"     ),
  attackSound   = audio.loadSound( "audio/attack.wav"     ),
  dangerSound   = audio.loadSound( "audio/danger3.wav"    ),
  enemyDefSound = audio.loadSound( "audio/danger.wav"     ),--enemyDef.wav"   ),
  npcGoodSound  = audio.loadSound( "audio/npc_good.wav"   ),
  npcEvilSound  = audio.loadSound( "audio/npc_evil.wav"   ),
  levelEndSound = audio.loadSound( "audio/level_ended.wav"),
  gameOverSound = audio.loadSound( "audio/game_over.wav"  ),
  buttonSound = audio.loadSound( "audio/buttonPress.wav"  ),
  clickSound = audio.loadSound("audio/click.mp3")
}

-- inizializzare i volumi e i canali dei diversi suoni
sfx.init = function()
	-- riserva 10 canali audio
   audio.reserveChannels(10)
   --sfx.masterVolume = audio.getVolume()  --print( "volume "..masterVolume )
   audio.setVolume( myData.settings.volumeBgm/100, { channel = 1 } )  --background music
   audio.setVolume( myData.settings.volumeSfx/100*0.66, { channel = 2 } )  --jump sound 100*0.66
   audio.setVolume( myData.settings.volumeSfx/100,  { channel = 3 } )  --coin sound
   audio.setVolume( myData.settings.volumeSfx/100,  { channel = 4 } )  --attack sound
   audio.setVolume( myData.settings.volumeSfx/100*0.5, { channel = 5 } )  --danger sound
   audio.setVolume( myData.settings.volumeSfx/100*0.8,  { channel = 6 } )  --boom sounds
   audio.setVolume( myData.settings.volumeSfx/100, { channel = 7 } )  --louder sounds
   audio.setVolume( 0,    { channel = 8 } )  --powerup music
   audio.setVolume( myData.settings.volumeSfx/100,  { channel = 9 } )  -- button sounds
   audio.setVolume( myData.settings.volumeSfx/100,  { channel = 10 } )
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
    audio.setVolume( 0, { channel=10 } )
end


sfx.setVolumeSound = function(level)
    audio.setVolume( level*0.66, { channel=2 } )
    audio.setVolume( level, { channel=3 } )
    audio.setVolume( level, { channel=4 } )
    audio.setVolume( level*0.5, { channel=5 } )
    audio.setVolume( level*0.8, { channel=6 } )
    audio.setVolume( level, { channel=7 } )
    audio.setVolume( level, { channel=9 } )
    audio.setVolume( level, { channel=10 } )
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

return sfx
