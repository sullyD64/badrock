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

		print(self.bossEntity.corpo.width)
			
			--self.bossEntity.manoSx.isFixedRotation=false
			--self.bossEntity.manoSx.rotation = 180
			--self.bossEntity.corpo:setFillColor( 255,0 ,0)
			--self.bossEntity.corpo:setFillColor(1)    --ripristina il colore originale

			--inizializazione di componenti aggiuntive di ogni pezzo
			self.bossEntity.spallaDx.state = "normal"
			self.bossEntity.spallaSx.state = "normal"
			self.bossEntity.spallaDx.proiettili = {}
			self.bossEntity.spallaSx.proiettili = {}
			self.bossEntity.spallaDx.timer = {}
			self.bossEntity.spallaSx.timer = {}
			self.bossEntity.manoDx.laser = nil
			self.bossEntity.manoSx.laser = nil
			
			
			print(" STA PER INIZIARE LA BOSS FIGHT")
			--phase1
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
				--self.bossEntity.manoDx.state = "alzaSchiaccia"
				--self.bossEntity.manoSx.state = "alzaSchiaccia"

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

		 	--La testa del boss diventa finalmente colpibile
		 	transition.to(self.bossEntity.testa,{time = 20, onComplete=function() self.bossEntity.testa.isBodyActive=true end })
		 	--Sposta il corpo del boss con tutto il resto verso l'alto
				transition.to(self.spawn, {time=4000, y= self.spawn.y - 200})
		 	-- da togliere--
		 	--transition.to(self.bossEntity.manoSx, {time=20, onComplete=function() self.bossEntity.manoSx.isBodyActive=false end})
		 	--transition.to(self.bossEntity.manoDx, {time=20, onComplete=function() self.bossEntity.manoDx.isBodyActive=false end})
		 	-------
		 	self.bossEntity.manoDx.state = "insegui"
			self.bossEntity.manoSx.state = "insegui"
			transition.to(self.bossEntity.manoDx,{time = 20, rotation = 180})
			transition.to(self.bossEntity.manoSx,{time = 20, rotation = 90})


			--Fa sparare laser dalle mani ogni Tot secondi per tot volte-------------------------
			local numSpari = 2
			local fireRate = 5000 --Se si riduce più di un tot potrebbe dare problemi con la somma dei timer interni di sparaLaser()
			local t1= timer.performWithDelay(fireRate, function() boss.sparaLaser(self.bossEntity.manoDx,self)	end, -1)
			local t2= timer.performWithDelay(fireRate, function() boss.sparaLaser(self.bossEntity.manoSx,self)	end, -1)
			table.insert(self.timers,t1)
			table.insert(self.timers,t2)

			--ogni num spari, le mani si "surriscaldano" e non sparano più per stopTime --------------------
			local stopTime=  5000 

			local nextStopTime= (fireRate * (numSpari+1)) --(numSpari +1) perchè do il tempo al timer di avviare il suo timer interno
			local t3= timer.performWithDelay(nextStopTime, function()
				--stop ai timer di sparaLaser
				timer.pause(t1)
				timer.pause(t2) 
				--Sposta il corpo del boss con tutto il resto verso il basso
				transition.to(self.spawn, {time=4000, y= self.spawn.y + 200})
				--Rende le mani rosse
				self.bossEntity.manoDx:setFillColor( 255,0 ,0)
				self.bossEntity.manoSx:setFillColor( 255,0 ,0)

				-- le mani ritornano al loro stato precedente dopo Tot secondi
				local t4 = timer.performWithDelay(stopTime,function()
					--Rende le mani normali (di colore)
					self.bossEntity.manoDx:setFillColor(1)
					self.bossEntity.manoSx:setFillColor(1)

					timer.resume(t1)
					timer.resume(t2)

					--Sposta il corpo del boss con tutto il resto verso l'alto
					transition.to(self.spawn, {time=4000, y= self.spawn.y - 200})
				end)
				table.insert(self.timers,t4)
	

			end , -1)
			table.insert(self.timers,t3)

			
		 	
		end

			
		function strategyB1:victory()
			self.state = "Completed"

			--pause all timers of this strategy
			for i,t in pairs(self.timers)do
				timer.pause(t)
			end

			timer.performWithDelay(5000,function() --dopo circa 10 sec
				self:terminateFight()
			end )
		
			print("Strategia COMPLETATA !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Boss Sconfitto")
		end



		function strategyB1:terminateFight()
			timer.performWithDelay(4000, function()
				self.state = "Terminated"
			end)
			--self.state = "Terminated"
			self.isActive=false

			for i,part in pairs(self.bossEntity)do
				if((part.name=="manoSx" or part.name=="manoDx") and part.laser) then
					--transition.cancel(part.laser)
					--display.remove(part.laser)
				end
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