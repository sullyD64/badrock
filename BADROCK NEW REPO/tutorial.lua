-----------------------------------------------------------------------------------------------------------------
-- Tutorial.lua
-- Il tutorial crea gli oggetti di cui necessita quando viene invocato il metodo create() (insieme alla creazione 
-- del livello), dopodiché a scena già iniziata si può dare inizio al tutorial tramite start(), si susseguiranno 
-- le istruzioni a schermo, ogni istruzione è collegata a una funzione che invocherà la funzione dell'istruzione
-- successiva, una volta termianto il suo compito 
-----------------------------------------------------------------------------------------------------------------

local utility = require ("menu.utilityMenu")
local ui = require ("core.ui")
local controller = require ("core.controller")

local tutorial = {}
local game

function tutorial.create(currentGame)
	tutorial.black = display.newImageRect ( visual.tutorialBlack, display.contentWidth, display.contentHeight)
	tutorial.black.anchorX = 0
	tutorial.black.anchorY = 0
	tutorial.black.alpha = 0

	tutorial.red = display.newImageRect ( visual.tutorialRed, display.contentWidth, display.contentHeight)
	tutorial.red.anchorX = 0
	tutorial.red.anchorY = 0
	tutorial.red.alpha = 0

	tutorial.textJump = display.newText( "", 0, 0, utility.font, 20 )
	tutorial.textJump.alpha = 0
	--tutorial.textJump:setFillColor( 0.85, 0.85, 0.85 )
	tutorial.text = display.newText( "", 0, 0, utility.font, 20 )
	tutorial.text.alpha = 0

	tutorial.arrow = display.newImageRect ( visual.tutorialArrow, 90, 65)
	tutorial.arrow.alpha = 0
	game = currentGame
end

local function gameResume()
	transition.fadeOut (tutorial.black,  { time=500 })
	tutorial.black:removeSelf()
	tutorial.red:removeSelf()
	tutorial.text:removeSelf()
	tutorial.textJump:removeSelf()
	tutorial.arrow:removeSelf()
	controller.pauseEnabled = true
	-- myData viene modificato e salvato per non far partire il tutorial dal prossimo avvio
	myData.firstStart = false
	-- SERVICE -------
	service.saveData()
	------------------

	game.state = "Resumed"
end


local function letStart()
	tutorial.text.text = "Let's start!"
	tutorial.text.size = 40
	tutorial.text.x = display.contentCenterX
	tutorial.text.y = display.contentCenterY
	transition.to( tutorial.text, { time=500, alpha=1 , delay = 800} )
	transition.to( tutorial.text, { time=500, alpha=0 , delay = 2250 , onComplete = gameResume} )
end

local function pause()
	tutorial.arrow.x = display.contentWidth - 110
	tutorial.arrow.y = display.screenOriginY + 60
	tutorial.arrow.xScale = -1
	tutorial.arrow.yScale = -1
	tutorial.arrow:toFront()
	tutorial.text.text = "Pause the game whenever you want!"
	tutorial.text.x = display.contentWidth - 180
	tutorial.text.y = display.screenOriginY + 110
	transition.to( tutorial.text, { time=500, alpha=1 , delay = 800} )
	transition.to( tutorial.arrow, { time=500, alpha=1 , delay = 800} )
	transition.to( tutorial.text, { time=500, alpha=0 , delay = 2450,  onComplete = letStart} )
	transition.to( tutorial.arrow, { time=500, alpha=0 , delay = 2450 } )
end


local function life()
	tutorial.arrow.x = display.screenOriginX + 155--130
	tutorial.arrow.y = display.screenOriginY + 50
	tutorial.arrow.yScale = -1
	tutorial.arrow.xScale = 1
	tutorial.text.text = "When your lives drop to \n      zero is game over"
	tutorial.text.x = display.screenOriginX + 195--170
	tutorial.text.y = display.screenOriginY + 115
	transition.to( tutorial.text, { time=500, alpha=1 , delay = 800} )
	transition.to( tutorial.arrow, { time=500, alpha=1 , delay = 800} )
	transition.to( tutorial.text, { time=500, alpha=0 , delay = 2550,  onComplete = pause } )
	transition.to( tutorial.arrow, { time=500, alpha=0 , delay = 2550 } )
end


local function score()
	tutorial.arrow.x = display.contentWidth - 240
	tutorial.arrow.y = display.screenOriginY + 50
	tutorial.arrow.xScale = -1
	tutorial.arrow.yScale = -1
	tutorial.text.text = "             This is your score,\n do your best by killing enemies \n      and interacting with npcs!"
	tutorial.text.x = display.contentWidth - 280 
	tutorial.text.y = display.screenOriginY + 115
	transition.to( tutorial.text, { time=500, alpha=1 , delay = 700} )
	transition.to( tutorial.arrow, { time=500, alpha=1 , delay = 700} )
	transition.to( tutorial.text, { time=500, alpha=0 , delay = 3200,  onComplete = life } )
	transition.to( tutorial.arrow, { time=500, alpha=0 , delay = 3200 } )
end


local function jump2()
	tutorial.textJump.text = "Hold to jump higher!"
	transition.to( tutorial.textJump, { time=500, alpha=1 , delay = 500} )
	transition.dissolve( tutorial.red, tutorial.black, 500, 2250 )
	transition.to( tutorial.textJump, { time=500, alpha=0 , delay = 2250,  onComplete = score } )
end


local function jump()
	tutorial.textJump.text = "Press anywhere to jump"
	tutorial.textJump.x = display.contentCenterX
	tutorial.textJump.y = display.contentCenterY
	transition.dissolve( tutorial.black, tutorial.red, 500, 800 )
	transition.to( tutorial.textJump, { time=500, alpha=1 , delay = 800} )
	transition.to( tutorial.textJump, { time=500, alpha=0 , delay = 2250,  onComplete = jump2 } )
end

local function attack()
	tutorial.arrow.x = display.contentWidth -130
	tutorial.arrow.y = display.contentHeight - 60
	tutorial.arrow.xScale = -1
	tutorial.text.text = "Press to attack"
	tutorial.text.x = display.contentWidth -150
	tutorial.text.y = display.contentHeight - 110
	transition.to( tutorial.text, { time=500, alpha=1 , delay = 800} )
	transition.to( tutorial.arrow, { time=500, alpha=1 , delay = 800} )
	transition.to( tutorial.text, { time=500, alpha=0 , delay = 2250, onComplete = jump } )
	transition.to( tutorial.arrow, { time=500, alpha=0 , delay = 2250 } )
end

local function move()
	tutorial.arrow.x = display.screenOriginX + 190
	tutorial.arrow.y = display.contentHeight - 80
	tutorial.text.text = "Use the arrows to move"
	tutorial.text.x = display.screenOriginX + 220--250
	tutorial.text.y = display.contentHeight - 130--170
	transition.to( tutorial.text, { time=500, alpha=1 , delay = 800 } )
	transition.to( tutorial.arrow, { time=500, alpha=1 , delay = 800 } )
	transition.to( tutorial.text, { time=500, alpha=0 , delay = 2250,  onComplete = attack } )
	transition.to( tutorial.arrow, { time=500, alpha=0 , delay = 2250 } )
end


function tutorial.start()
transition.fadeIn (tutorial.black,  { time=500 })
ui.buttonGroup:toFront()
controller.pauseEnabled = false
move()
--letStart()
end

-- --tutorial.text.text = "This is Steve, you control him"

return tutorial
