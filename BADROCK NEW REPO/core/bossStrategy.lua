-----------------------------------------------------------------------------------------
-- bossStrategy.lua
-- Used to store the boss event phases for every boss
--
-----------------------------------------------------------------------------------------
local boss= require("core.boss")
local physics = require ("physics")
local entity = require("lib.entity")

local game = {}
local steve = {}
local gState = {}
local sState = {}

local bossStrategy = {
	activeStrategy = 0
}

local strategyBoss1 = {}

	function strategyBoss1.createStrategy()

		local strategyB1 = {}
		strategyB1.isActive = false
		strategyB1.BossNumber= 1
 		strategyB1.bossEntity = {}
 		strategyB1.phase = 0
		strategyB1.state = ""
		strategyB1.timers={}
		strategyB1.fireRateSx = 5000
		strategyB1.fireRateDx = 5000
		strategyB1.spawn = game.map:getObjectLayer("bossSpawn"):getObject("spawn00")
		

	

		function strategyB1:startFight()
		
			self:phase0()
		end
		
		function strategyB1:phase0()
		
			bossStrategy.activeStrategy = 1
			self.isActive = true
			self.state = "generating"
			self.phase=0
			
			local corpo = boss.loadBoss("corpo")
			local spallaDx = boss.loadBoss("spallaDx")
			local spallaSx = boss.loadBoss ("spallaSx")	
			local testa = boss.loadBoss("testa")
			local manoDx = boss.loadBoss("manoDx")
			local manoSx = boss.loadBoss("manoSx")
			corpo:toBack()

			-- sposta le mani nella posizione iniziale
			manoSx.x = self.spawn.x -100
			manoDx.x = self.spawn.x +100
			--xScale degli oggetti identici
			manoDx.xScale=-1
			spallaSx.xScale=-1
			
			
			self.bossEntity.manoDx = manoDx
			self.bossEntity.manoSx = manoSx
			self.bossEntity.spallaDx = spallaDx
			self.bossEntity.spallaSx = spallaSx
			self.bossEntity.corpo = corpo
			self.bossEntity.testa = testa 
			
			--self.bossEntity.corpo:setFillColor( 255,0 ,0)
			--self.bossEntity.corpo:setFillColor(1)    --ripristina il colore originale

			--inizializazione di componenti aggiuntive di ogni pezzo
			self.bossEntity.spallaDx.state = "normal"
			self.bossEntity.spallaSx.state = "normal"
			self.bossEntity.spallaDx.proiettili = {}
			self.bossEntity.spallaSx.proiettili = {}
			self.bossEntity.spallaDx.timer = {}
			self.bossEntity.spallaSx.timer = {}
			self.bossEntity.manoDx.lasers = {}
			self.bossEntity.manoSx.lasers = {}
			
			
			print(" STA PER INIZIARE LA BOSS FIGHT")
			timer.performWithDelay(3000,self:phase1())
		end



		function strategyB1:phase1()
				self.state = "Running"
				self.phase=1
				print("PHASE = 1")
			
				--local manoDx = self.bossEntity.manoDx  
				--local manoSX = self.bossEntity.manoSx
				
				self.bossEntity.manoDx.state = "bouncing"
				self.bossEntity.manoSx.state = "bouncing"

				-- Alcune parti non possono essere toccate durante alcune fasi--------
				self.bossEntity.spallaDx.isTargettable =false
				self.bossEntity.spallaSx.isTargettable =false
				self.bossEntity.spallaDx.isBodyActive = false
				self.bossEntity.spallaSx.isBodyActive = false
				self.bossEntity.testa.isTargettable =false
				self.bossEntity.testa.isBodyActive = false
				

				--DA RIMUOVERE, SOLO PER SEMPLIFICARE I TEST
				self.bossEntity.manoDx.state = "alzaSchiaccia"
				self.bossEntity.manoSx.state = "alzaSchiaccia"

				--Sposta il corpo del boss con tutto il resto verso l'alto
				transition.to(self.spawn, {time=4000, y= self.spawn.y - 200})

				-- Funzione che fa muovere le mani ogni tot secondi----------
				local t1
				local muoviMani = function()
					if(self.phase==1 and self.state ~= "Terminated") then
						local d1 = math.random(-50,50)
						local d2 = math.random(-50,50)
						if(self.bossEntity.manoDx and self.bossEntity.manoDx.lives > 1)then 
							self.bossEntity.manoDx:applyLinearImpulse(d1,-20,self.bossEntity.manoDx.x,self.bossEntity.manoDx.y) 
						end
						if(self.bossEntity.manoSx and self.bossEntity.manoSx.lives > 1)then
							self.bossEntity.manoSx:applyLinearImpulse(d2,-20,self.bossEntity.manoSx.x,self.bossEntity.manoSx.y)
						end
					else
						timer.cancel(t1)
					end
				end
				t1 = timer.performWithDelay(5000, muoviMani, -1)
				table.insert(self.timers,t)
		end


		function strategyB1:phase2()
			self.phase=2

		 	print("PHASE = 2")

		 	if(self.bossEntity.spallaDx.state == "normal") then
		 		self.bossEntity.spallaDx.isTargettable =true
		 		self.bossEntity.spallaDx.isBodyActive = true
		 	end
		 	if(self.bossEntity.spallaSx.state == "normal") then
				self.bossEntity.spallaSx.isTargettable =true
				self.bossEntity.spallaSx.isBodyActive =true
			end

			--Sposta il corpo del boss con tutto il resto verso il basso
			if(self.bossEntity.spallaSx.state == "normal" and self.bossEntity.spallaDx.state == "normal") then
				transition.to(self.spawn, {time=4000, y= self.spawn.y + 200})
			end

		 	local function sparaSx()
		 		local spallaSx=self.bossEntity.spallaSx
		 		if(spallaSx)then
		 			boss.spara(spallaSx, game.steve)
		 		end
		 	end
		 	local function sparaDx()
		 		local spallaDx=self.bossEntity.spallaDx
		 		if(spallaDx)then
		 			local t = timer.performWithDelay(1000,function()	boss.spara(spallaDx, game.steve) end)
		 			table.insert(self.timers,t)
		 		end
		 	end

		 	if(self.bossEntity.spallaSx.lives > 0 ) then
		 		local t1= timer.performWithDelay(self.fireRateSx, sparaSx , -1)
		 		table.insert(self.bossEntity.spallaSx.timer, t1)
		 		table.insert(self.timers, t1)
		 	end
		 	if(self.bossEntity.spallaDx.lives > 0 ) then
		 		local t2= timer.performWithDelay(self.fireRateDx, sparaDx , -1)
		 		table.insert(self.bossEntity.spallaDx.timer, t2)
		 		table.insert(self.timers, t2)
		 	end

		 	
		 	

		 	


		end

		function strategyB1:phase3()
			self.phase=3
		 	print("PHASE = 3")
		 	
		 	self.bossEntity.manoDx.state = "insegui"
			self.bossEntity.manoSx.state = "insegui"

		 	
		end

			




		function strategyB1:terminateFight()
			self.state = "Terminated"

			for i,part in pairs(self.bossEntity)do
				transition.cancel(part)
				display.remove(part)
			end	

			--cancel all timers of this strategy
			for i,t in pairs(self.timers)do
				timer.cancel(t)
			end



			print("Strategia Terminata TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")
		end

		function strategyB1:pauseFight()

			self.state = "Paused"
			--pause all transitions for the boss parts
			for i,part in pairs(self.bossEntity)do
				transition.pause(part)
				if(part.name=="spallaSx" or part.name=="spallaDx") then
					for i,proiettile in pairs(part.proiettili)do
						transition.pause(proiettile)
					end
				end
			end	

			--pause all timers of this strategy
			for i,t in pairs(self.timers)do
				timer.pause(t)
			end	

			print("Strategia in Pausa PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP")
			print(self.state)
		end

		function strategyB1:resumeFight()
			self.state = "Running"
			--pause all transitions for the boss parts
			for i,part in pairs(self.bossEntity)do
				transition.resume(part)
				if(part.name=="spallaSx" or part.name=="spallaDx") then
					for i,proiettile in pairs(part.proiettili)do
						transition.resume(proiettile)
					end
				end
			end	

			--pause all timers of this strategy
			for i,t in pairs(self.timers)do
				timer.resume(t)
			end	
			print("Strategia Resumata RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR")
			print(self.state)
		end













		strategyB1.__index = strategyB1
		return strategyB1
	end

		


		
			
		-- local function phase2()
		-- 	Bphase=2
		-- 	print("PHASE = 2")
		-- end,


		-- local function phase3()
		-- 	Bphase=3
		-- 	print("PHASE = 3")
		-- end,




	


		local function phaseEnd()
			--Runtime:removeEventListener("enterFrame",controlFlux)
			strategyB1:terminateFight()
			--altro
		end

		
		
		
		
		--Runtime:addEventListener("enterFrame",controlFlux)
		--phase0()
		
		

	


function bossStrategy.setGame( currentGame, gameStateList, playerStateList )
	game = currentGame
	if (game) then 
		steve = currentGame.steve 
	end
	gState = gameStateList
	sState = playerStateList
end


function bossStrategy.startBossFight(num)

--	in base al numero faccio partire una determinata bossFight
--	faccio partire la funzione phase0 di quella determinata BossStrategy

	boss.setGame(game,gState,sState)
	game.bossFight = strategyBoss1.createStrategy()
	game.bossFight:startFight()
end

return bossStrategy