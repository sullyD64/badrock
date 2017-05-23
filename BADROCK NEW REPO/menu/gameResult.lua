-- Visualizza un menu a pannello una volta richiamato onGameOver a causa di morte o della fine del livello
-- che mostra l'output (se positivo o negativo), il punteggio, le stelle(WIP) e tre tasti per scegliere se
-- riprovare il livello, andare al prossimo o andare al menu,
-- una volta premuto uno dei tasti viene impostata game.nextScene e lo stato del gioco viene impostato ad ENDED

local widget   = require ( "widget"           )
local utility  = require ( "menu.utilityMenu" )
local myData  = require ( "myData" )

local result = {}

local lvl = 0
------------------------------------------------
-- This is required for triggering a change in game's state

local game = {}
local stateList = {}
local finalText = display.newText ("", 0, -50, native.systemFontBold, 34)
local finalScore = display.newText( "", 0, -70, "Micolas.ttf", 15 )

function result.setGame( currentGame, gameStates )
	game = currentGame
	stateList = gameStates
	level = game.currentLevel
	finalScore.text = game.score --myData.settings.levels[game.currentLevel].score
end
-------------------------------------------------
-- -------------------------------------------------
function result.setOutcome(outcome)
		if (outcome == "Completed") then
			finalText.text = "Congratulations!"
			finalText:setFillColor( 0.75, 0.8, 1 )
		elseif (outcome == "Failed") then
			finalText.text = "Level Failed"
			finalText:setFillColor( 1, 0, 0 )
		end
	end
-- -------------------------------------------------


-- result MENU ---------------------------------------------------------------------

	-- Return to the main Menu
	local function onMenuBtnRelease()  
		result.panel:hide({
			speed = 250,
			transition = easing.outElastic
		})
		audio.fadeOut(1,100)
		audio.stop(1)

		game.nextScene = "mainMenu"
		game.state = stateList.ENDED
		return true
	end

	-- Try again the same level
	local function onRetryBtnRelease()  
		result.panel:hide({
			speed = 250,
			transition = easing.outElastic
		})
		audio.fadeOut(1,100)
		audio.stop(1)

		-- cambiare il game state per andare di nuovo al livello
		game.nextScene = "level"..level
		game.state = stateList.ENDED
		return true
	end

	-- Go to the next level
	local function onNextLevelBtnRelease()  
		result.panel:hide({
			speed = 250,
			transition = easing.outElastic
		})
		audio.fadeOut(1,100)
		audio.stop(1)

		-- cambiare il game state per andare al prossimo livello
		game.nextScene = "level"..level+1
		game.state = gState.ENDED

		return true
	end


	-- Create the result panel
	result.panel = utility.newPanel{
			location = "custom",
			onComplete = panelTransDone,
			width = display.contentWidth * 0.35,
			height = display.contentHeight * 0.65,
			speed = 250,
			anchorX = 0.5,
			anchorY = 1.0,
			x = display.contentCenterX,
			y = display.screenOriginY,
			inEasing = easing.outBack,
			outEasing = easing.outCubic
			}
			result.panel.background = display.newImageRect(visual.panel,result.panel.width, result.panel.height-20)
			result.panel:insert( result.panel.background )
			 
			-- result.panel.title = display.newText( "result", 0, -70, "Micolas.ttf", 15 )
			-- result.panel.title:setFillColor( 1, 1, 1 )
			-- result.panel:insert( result.panel.title )

	-- Create the buttons ------------------------------------------------------------
		-- Create the return to menu button
		result.panel.menuBtn = widget.newButton {
			label = "Menu",
			onRelease = onMenuBtnRelease,
			emboss = false,
			shape = "roundedRect",
			width = 40,
			height = 15,
			cornerRadius = 2,
			fillColor = { default={0.78,0.79,0.78,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={0,0,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 1,
			}
			result.panel.menuBtn.x= -60
			result.panel.menuBtn.y = 39
			result.panel:insert(result.panel.menuBtn)
			print("livelloP "..lvl)

		result.panel.retryBtn = widget.newButton {
			label = "Retry",
			fontSize = 10,
			labelColor = { default={0}, over={1} },
			onRelease = onRetryBtnRelease,
			emboss = false,
			shape = "roundedRect",
			width = 30,
			height = 15,
			cornerRadius = 2,
			fillColor = { default={0.78,0.79,0.78,1}, over={0.2,0.2,0.3,0.4} },--default={0.26,0.17,0.53,1}, over={1,0.1,0.7,0.4} },--{ default={1,0,0,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={0,0,0,1}, over={1,1,1,1} },--default={1,0.4,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 1,
			}
			result.panel.retryBtn.x= -20
			result.panel.retryBtn.y = 39
			result.panel:insert(result.panel.retryBtn)

		result.panel.nextLevelBtn = widget.newButton {
			label = "Next",
			fontSize = 10,
			labelColor = { default={0}, over={1} },
			onRelease = onNextLevelBtnRelease,
			emboss = false,
			shape = "roundedRect",
			width = 30,
			height = 15,
			cornerRadius = 2,
			fillColor = { default={0.78,0.79,0.78,1}, over={0.2,0.2,0.3,0.4} },--default={0.26,0.17,0.53,1}, over={1,0.1,0.7,0.4} },--{ default={1,0,0,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={0,0,0,1}, over={1,1,1,1} },--default={1,0.4,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 1,
			}
			result.panel.nextLevelBtn.x= 15
			result.panel.nextLevelBtn.y = 39
			result.panel:insert(result.panel.nextLevelBtn)
	-- -------------------------------------------------------------------------------

	-- Create text result, score, and stars ------------------------------------------
		
		result.panel.text= finalText
		result.panel:insert( result.panel.text )
		
		--result.panel.score = display.newText( myData.settings.levels[1].score, 0, -70, "Micolas.ttf", 15 )

		result.panel.score = finalScore
		result.panel.score:setFillColor( 1, 1, 1 )
		result.panel:insert( result.panel.score )

		-- -- Generate the star
		-- local lvl = game.lvl
		-- result.panel.star = {}
		-- if myData.settings.levels[1] and myData.settings.levels[1].stars then --and myData.settings.levels[i].stars > 0 then
		-- 		for j = 1, 3 do --myData.settings.levels[i].stars do
		-- 			result.panel.star[j] = display.newImageRect(visual.levelSelectStar , 60,58)
		-- 			if j>myData.settings.levels[1].stars then
		-- 				result.panel.star[j].alpha = 0.2
		-- 			end
		-- 			result.panel.star[j].x = display.contentCenterX + (j * 25) + 50
		-- 			result.panel.star[j].y = display.contentCenterY
		-- 			result.panel:insert(result.panel.star[j])
		-- 		end
		-- end
	-- -------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------

return result