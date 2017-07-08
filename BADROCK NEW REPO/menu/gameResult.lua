-- Visualizza un menu a pannello una volta richiamato onGameOver a causa di morte o della fine del livello
-- che mostra l'output (se positivo o negativo), il punteggio, le stelle(WIP) e tre tasti per scegliere se
-- riprovare il livello, andare al prossimo o andare al menu,
-- una volta premuto uno dei tasti viene impostata game.nextScene e lo stato del gioco viene impostato ad ENDED

local widget   = require ( "widget"           )
local utility  = require ( "menu.utilityMenu" )
local myData  = require ( "myData" )

local result = {}

------------------------------------------------
-- This is required for triggering a change in game's state

local game = {}
local stateList = {}
--local finalText = display.newText ("", 0, -50, native.systemFontBold, 34)
--local finalScore = display.newText( "", 0, -70, "Micolas.ttf", 15 )
local stars = {}
local level = myData.settings.currentLevel

function result.setStars(game, outcome)
	if (outcome == "Completed") then
		for j = 1, 3 do --myData.settings.levels[i].stars do
			if j<=game.stars then
				result.panel.star[j].alpha = 1
			else 
				result.panel.star[j].alpha = 0.3
			end		
		end
		print(game.stars)
	elseif (outcome == "Failed") then
		for j = 1, 3 do
			result.panel.star[j].alpha = 0
		end
	end
end



function result.setGame( currentGame, gameStates, outcome )
	game = currentGame
	stateList = gameStates

	if (outcome == "Completed") then
		-- decide che testo viene mostrato a schermo
		result.panel.finalText.text = "You win!"
		result.panel.finalText:setFillColor( 0, 0.7, 0)--0.75, 0.8, 1 )

		--abilita o disabilita il tasto per passare al livello successivo
		-- meglio se outcome è completed o mydata.score già esiste?
		result.panel.nextLevelBtn.alpha = 1,
		result.panel.nextLevelBtn:setEnabled( true )

		--result.panel.score.text = game.score --myData.settings.levels[game.currentLevel].score  --QUA
		
	elseif (outcome == "Failed") then
		result.panel.finalText.text = "Level Failed"
		result.panel.finalText:setFillColor( 1, 0, 0 )

		result.panel.nextLevelBtn.alpha = 0.3, -- possibile mettere anche un'immagine diversa, da decidere
		result.panel.nextLevelBtn:setEnabled( false )

		-- result.panel.score.text = ""   -- [L'ho commentato io, dava problemi]
	end
	result.setStars(game, outcome)

end
-------------------------------------------------

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
		game.nextScene = "level"..tonumber(level)+1
		game.state = stateList.ENDED

		return true
	end


	-- Create the result panel
	result.panel = utility.newPanel{
			location = "custom",
			onComplete = panelTransDone,
			width = 220,--display.contentWidth * 0.35,
			height = 260,--display.contentHeight * 0.65,
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

	-- Create the buttons ------------------------------------------------------------
		
		-- Create the return to menu button
		result.panel.menuBtn = widget.newButton {
			onRelease = onMenuBtnRelease,
			emboss = false,
			defaultFile = visual.backToMenuImg,
			width = 35,
			height = 37,
			}
			result.panel.menuBtn.x= -50
			result.panel.menuBtn.y = result.panel.contentCenterY
			result.panel:insert(result.panel.menuBtn)
			--print("livelloP "..lvl)

		result.panel.retryBtn = widget.newButton {
			onRelease = onRetryBtnRelease,
			defaultFile = visual.retryImg,
			emboss = false,
			width = 26,
			height = 27,
			cornerRadius = 2,
			}
			result.panel.retryBtn.x= -20
			result.panel.retryBtn.y = result.panel.contentCenterY
			result.panel:insert(result.panel.retryBtn)

		result.panel.nextLevelBtn = widget.newButton {
			onRelease = onNextLevelBtnRelease,
			defaultFile = visual.nextLevelImg,
			emboss = false,
			width = 26,
			height = 27,
			}
			result.panel.nextLevelBtn.x= 10
			result.panel.nextLevelBtn.y = result.panel.contentCenterY

			result.panel:insert(result.panel.nextLevelBtn)
	-- -------------------------------------------------------------------------------

	-- Create text result, score, and stars ------------------------------------------
		
		result.panel.finalText= display.newText ("", 5, -92, utility.font, 17)
		result.panel:insert( result.panel.finalText )

		-- result.panel.score = display.newText( "", 0, -100, utility.font, 15 )  -- QUA
		-- result.panel.score:setFillColor( 1, 1, 1 )
		-- result.panel:insert( result.panel.score )

		-- Generate the star
		result.panel.star = {}
				for j = 1, 3 do --myData.settings.levels[i].stars do
					result.panel.star[j] = display.newImageRect(visual.levelSelectStar , 30,28)
					result.panel.star[j].x = -60 + (j * 25) + 10 --display.contentCenterX + (j * 25) + 50
					result.panel.star[j].y = -30--result.panel.contentCenterY
					result.panel.star[j].alpha = 0
					result.panel:insert(result.panel.star[j])
				end
	-- -------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------

return result