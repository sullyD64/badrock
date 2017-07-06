-----------------------------------------------------------------------------------------
-- bossStrategy.lua
-- Used to store the boss event phases for every boss
--
-----------------------------------------------------------------------------------------
local boss= require("core.boss")

local game = {}
local steve = {}
local gState = {}
local sState = {}

local bossStrategy = {
	-- activeStrategy se == 0 -->non c'è nessuna fight, altrimenti indica il numero della Boss Strategy attiva  
	activeStrategy = 0
}

---------- STRATEGIA BOSS 1 --------------------------------------------------------------------------------------------------------------------
local strategyBoss1 = {}

	function strategyBoss1.createStrategy(trigger)

		local strategyB1 = {}
		strategyB1.trigger = trigger 
		strategyB1.isActive = false
		strategyB1.BossNumber= 1
 		strategyB1.bossEntity = {}
 		strategyB1.phase = 0
		strategyB1.state = ""
		strategyB1.timers={}          --campo opzionale per altre strategy
		strategyB1.fireRateSx = 5000  --campo opzionale per altre strategy
		strategyB1.fireRateDx = 5000  --campo opzionale per altre strategy
		strategyB1.spawn = game.map:getObjectLayer("bossSpawn"):getObject("bossSpawn")
		strategyB1.win = false
		

	
		-- funzione obbligatoriamente presente in ogni strategy
		function strategyB1:startFight()
			self:phase0()
		end
		
		------ PHASE 0 --------------------------------------------------------------------------------------------------------------------
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
			self.bossEntity.spawn = self.spawn

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
			local t = timer.performWithDelay(3000,self:phase1())
			table.insert(self.timers,t)
		end



		------ PHASE 1 --------------------------------------------------------------------------------------------------------------------
		function strategyB1:phase1()

				self.state = "Running"
				self.phase=1
				print("PHASE = 1")
				
				self.bossEntity.manoDx.state = "bouncing"
				self.bossEntity.manoSx.state = "bouncing"

				-- Alcune parti non possono essere toccate durante alcune fasi--------
				self.bossEntity.spallaDx.isTargettable =false
				self.bossEntity.spallaSx.isTargettable =false
				self.bossEntity.testa.isTargettable =false

				--DA RIMUOVERE, SOLO PER SEMPLIFICARE I TEST
				--self.bossEntity.manoDx.state = "alzaSchiaccia"
				--self.bossEntity.manoSx.state = "alzaSchiaccia"

				--Sposta il corpo del boss con tutto il resto verso l'alto
				transition.to(self.spawn, {time=4000, y= self.spawn.y - 150})

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


		------ PHASE 2 --------------------------------------------------------------------------------------------------------------------
		function strategyB1:phase2()
			self.phase=2

		 	print("PHASE = 2")

		 	if(self.bossEntity.spallaDx.state == "normal") then
		 		self.bossEntity.spallaDx.isTargettable =true
		 	end
		 	if(self.bossEntity.spallaSx.state == "normal") then
				self.bossEntity.spallaSx.isTargettable =true
			end

			--Sposta il corpo del boss con tutto il resto verso il basso
			if(self.bossEntity.spallaSx.state == "normal" and self.bossEntity.spallaDx.state == "normal") then
				transition.to(self.spawn, {time=4000, y= self.spawn.y + 150})
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

		------ PHASE 3 --------------------------------------------------------------------------------------------------------------------
		function strategyB1:phase3()
			self.phase=3
		 	print("PHASE = 3")

		 	--La testa del boss diventa finalmente colpibile
		 	transition.to(self.bossEntity.testa,{time = 5000, onComplete=function() self.bossEntity.testa.isTargettable=true end })
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
			self.win = true
			--pause all timers of this strategy
			for i,t in pairs(self.timers)do
				timer.pause(t)
			end

			timer.performWithDelay(5000,function() --dopo circa 5 sec
				self:terminateFight()
			end )
		end


		-- TERMINATE BOSS FIGHT --------------------------(called if we: die|return to menu|after victory)----
		function strategyB1:terminateFight()
			self.state = "Terminated"
			--IL DELAY DEVE ESSERE CIRCA UGUALE AL TEMPO DI RESPAWN DI STEVE
			timer.performWithDelay(1000, function()
				self.isActive=false
				bossStrategy.activeStrategy=0

				--cancel all transitions and images
				for i,part in pairs(self.bossEntity)do			
					transition.cancel(part)
					display.remove(part)
				end	

				--cancel all timers of this strategy
				for i,t in pairs(self.timers)do
					timer.cancel(t)
				end

				-- remove the triggered wall at the beginning
				util.destroyWalls(game.map)
				
				-- if we don't defeat the Boss, reactivate the boss Trigger (usefull in case we died)
				transition.to(self.trigger,{time=0, onComplete= function()
					if(self.win == false)then
					 	self.trigger.isBodyActive=true
					end 
				end})
				game.bossFight=nil
			end)
		end

		-- PAUSE BOSS FIGHT -----------------------------------------------------------------------------------
		function strategyB1:pauseFight()
			self.state = "Paused"

			--pause all transitions for the boss parts
			for i,part in pairs(self.bossEntity)do
				transition.pause(part)
				if(part.name=="spallaSx" or part.name=="spallaDx") then
					for i,proiettile in pairs(part.proiettili)do
						transition.pause(proiettile)
					end
				elseif(part.name=="manoSx" or part.name=="manoDx") then
					transition.pause(part.laser)
				end
			end	

			--pause all timers of this strategy
			for i,t in pairs(self.timers)do
				timer.pause(t)
			end	

			--pause all sprites for the boss parts
			for i,part in pairs(self.bossEntity)do
				--part:pause()
				if(part.name=="manoSx" or part.name=="manoDx") then
					if(part.laser) then	if(part.laser.isPlaying)then	part.laser:pause() end  end
					--end
				end
			end
		end

		--RESUME BOSS FIGHT---------------------------------------------------------------------------------
		function strategyB1:resumeFight()
			self.state = "Running"

			--resume all transitions for the boss parts
			for i,part in pairs(self.bossEntity)do
				transition.resume(part)
				if(part.name=="spallaSx" or part.name=="spallaDx") then
					for i,proiettile in pairs(part.proiettili)do
						transition.resume(proiettile)
					end
				elseif(part.name=="manoSx" or part.name=="manoDx") then
					transition.resume(part.laser)
				end
			end	

			--resume all timers of this strategy
			for i,t in pairs(self.timers)do
				timer.resume(t)
			end	

			--resume all sprites for the boss parts
			for i,part in pairs(self.bossEntity)do
				--part:play()
				if(part.name=="manoSx" or part.name=="manoDx") then
					--for i,laser in pairs(part.laser)do
					if(part.laser) then	if(part.laser.isPlaying == false)then	part.laser:play() end end
					--end
				end
			end
		end

		-- MAIN LOOP ---------------------------------------------------------------------------------------
		function strategyB1:executeRuntimeLoop()
			if(self.isActive == true ) then

				local bossEntity = self.bossEntity

				-- Keeps the Boss Pieces all tied together ----
				if(bossEntity.spallaDx and bossEntity.spallaDx.lives >0) then
					bossEntity.spallaDx.x = self.spawn.x +73
					bossEntity.spallaDx.y = self.spawn.y-17
				end
				if(bossEntity.spallaSx and bossEntity.spallaSx.lives>0 ) then
					bossEntity.spallaSx.x = self.spawn.x -73
					bossEntity.spallaSx.y = self.spawn.y-17
				end
				if(bossEntity.testa and bossEntity.testa.lives > 0) then
					bossEntity.testa.x = self.spawn.x 
					bossEntity.testa.y = self.spawn.y -35
				end
				if(bossEntity.corpo and bossEntity.corpo.lives > 0) then
					bossEntity.corpo.x = self.spawn.x 
					bossEntity.corpo.y = self.spawn.y +90
				end

				-- Phase 1 -------------------------------------------------

				if(self.phase == 1) then
					if(bossEntity.manoDx.lives==2 and bossEntity.manoDx.state == "bouncing")then
						bossEntity.manoDx:setFillColor( 255,0 ,0)
						local t=timer.performWithDelay(250, function()	bossEntity.manoDx:setFillColor(1) end)
						table.insert(self.timers , t)

						bossEntity.manoDx.state="alzaSchiaccia"
						bossEntity.manoDx.bounce = 0
						boss.alzaSchiaccia(bossEntity.manoDx , game.steve, self)
					end
					if(bossEntity.manoSx.lives==2 and bossEntity.manoSx.state == "bouncing")then
						bossEntity.manoSx:setFillColor( 255,0 ,0)
						local t= timer.performWithDelay(250, function()	bossEntity.manoSx:setFillColor(1) end)
						table.insert(self.timers , t)

						bossEntity.manoSx.state="alzaSchiaccia"
						bossEntity.manoSx.bounce = 0
						boss.alzaSchiaccia(bossEntity.manoSx , game.steve, self)
					end
					---------------------------------------------------------------
					-- Le mani tornano in aria se perdono tutta la vita------------
					if(bossEntity.manoDx.lives == 1 and bossEntity.manoDx.state == "alzaSchiaccia") then
						bossEntity.manoDx:setFillColor( 255,0 ,0)
						local t=timer.performWithDelay(250, function()	bossEntity.manoDx:setFillColor(1) end)
						table.insert(self.timers , t)

						bossEntity.manoDx.state = "sconfitta"
						bossEntity.manoDx.isBodyActive=false
						transition.to(bossEntity.manoDx, {time= 4000,  x = self.spawn.x +250, y = self.spawn.y})
					end
					if(bossEntity.manoSx.lives == 1 and bossEntity.manoSx.state == "alzaSchiaccia") then
						bossEntity.manoSx:setFillColor( 255,0 ,0)
						local t= timer.performWithDelay(250, function()	bossEntity.manoSx:setFillColor(1) end)
						table.insert(self.timers , t)

						bossEntity.manoSx.state = "sconfitta"
						bossEntity.manoSx.isBodyActive=false
						transition.to(bossEntity.manoSx, {time= 4000, x = self.spawn.x -250, y = self.spawn.y})
					end
					---------------------------------------------------------------
					-- Se entrambe le mani sono sconfitte parte la fase 2 ---------
					if(bossEntity.manoDx.state=="sconfitta" and bossEntity.manoSx.state=="sconfitta" and self.phase ~= 2)then
						--timer.cancel(t)
						timer.performWithDelay(5000, self:phase2())
					end
				end

				-- Phase 2 -------------------------------------------------
				if(self.phase == 2) then
					----------------------------
					local maxFireRate = 800		-- viene inizializzato ad ogni frame : cambiare
					----------------------------

					if(bossEntity.spallaDx.lives==1 and bossEntity.spallaDx.state == "normal") then
						bossEntity.spallaDx:setFillColor( 255,0 ,0)
						local t= timer.performWithDelay(250, function()	bossEntity.spallaDx:setFillColor(1) end)
						table.insert(self.timers , t)

						bossEntity.spallaDx.state = "rage"
						bossEntity.spallaDx.isTargettable=false
						timer.performWithDelay(2000,function() bossEntity.spallaDx.isTargettable=true	end)
						self.fireRateDx= maxFireRate
						for i,t in pairs(bossEntity.spallaDx.timer)do
							timer.cancel(t)
						end
						self:phase2()
					end

					if(bossEntity.spallaSx.lives==1 and bossEntity.spallaSx.state == "normal") then
						bossEntity.spallaSx:setFillColor( 255,0 ,0)
						local t= timer.performWithDelay(250, function()	bossEntity.spallaSx:setFillColor(1) end)
						table.insert(self.timers , t)
						
						bossEntity.spallaSx.state = "rage"
						bossEntity.spallaSx.isTargettable=false
						timer.performWithDelay(2000,function() bossEntity.spallaSx.isTargettable=true	end)
						self.fireRateSx= maxFireRate
						for i,t in pairs(bossEntity.spallaSx.timer)do
							timer.cancel(t)
						end
						self:phase2()
					end

					if(bossEntity.spallaSx.lives==0) then
						for i,t in pairs(bossEntity.spallaSx.timer)do
							timer.cancel(t)
						end
						for i,c in pairs(bossEntity.spallaSx.proiettili)do

							if(c) then
								transition.cancel(c)
								transition.to(c,{time=0, alpha=0,onComplete=function()
									display.remove(c)
									c=nil end})
							end
						end
					end
					if(bossEntity.spallaDx.lives==0 ) then
						for i,t in pairs(bossEntity.spallaDx.timer)do
							timer.cancel(t)
						end
						for i,c in pairs(bossEntity.spallaDx.proiettili)do
							if(c) then
								transition.cancel(c)
								transition.to(c,{time=0, alpha=0,onComplete=function()
									display.remove(c)
									c=nil end})
							end
						end
					end
					if((bossEntity.spallaDx.lives==0 and bossEntity.spallaSx.lives==0) or not(bossEntity.spallaDx and bossEntity.spallaSx))then
						if(self.phase ~= 3)then
							timer.performWithDelay(4000,self:phase3())
						end
					end
				end

				-- Phase 3 -------------------------------------------------
				if(self.phase == 3)then
					-- Move the hands based on their state during this phase----
						if(bossEntity.manoSx.state == "insegui")then
							bossEntity.manoSx.x =	game.steve.x -240
							bossEntity.manoSx.y = game.steve.y
						end
						if(bossEntity.manoDx.state == "insegui") then
							bossEntity.manoDx.x = game.steve.x
							bossEntity.manoDx.y =  game.steve.y -150
						end
					---------------------------------------------------------------
					--Keeps the lasers in the position where they are fired------
						local laser= bossEntity.manoDx.laser
						if(laser)then
							laser.x = laser.fixedX
							laser.y = laser.fixedY
						end
						local laser = bossEntity.manoSx.laser
						if(laser)then
							laser.x = laser.fixedX
							laser.y = laser.fixedY
						end
					--------------------------------------------------------------
					if(bossEntity.testa.lives == 0 and self.state ~= "Completed" and self.win == false) then
						bossEntity.manoDx.state = "terminata"
						bossEntity.manoSx.state = "terminata"
						self:victory()
					end
				end
			end
		end

	strategyB1.__index = strategyB1
	return strategyB1
end
---------FINE STRATEGIA BOSS 1 ----------------------------------------------------------------------------------------------------



function bossStrategy.setGame( currentGame, gameStateList, playerStateList )
	game = currentGame
	if (game) then 
		steve = currentGame.steve 
	end
	gState = gameStateList
	sState = playerStateList
end

function bossStrategy.loadBoss( trigger )
	boss.setGame(game,gState,sState)
	local strategy

	if    (trigger.bossIndex == 1) then
		strategy = strategyBoss1.createStrategy(trigger)
	elseif(trigger.bossIndex == 2) then
	--  strategy = strategyBoss2.createStrategy(trigger)
	end

	trigger:addProperty(Property:new("categoryBits", filters.envFilter.categoryBits))
	trigger:addProperty(Property:new("maskBits", filters.envFilter.maskBits))
				
	trigger.listener = function(event)
		--Da mettere anche nei prossimi trigger per evitare un doppio contatto del trigger in breve tempo
		-- transition.to(event, {time = 0, 
		-- 	onComplete = function()
		-- 		event.contact.isEnabled = false
		-- 		transition.to(trigger, {time = 0, 
		-- 			onComplete = function()	
		-- 				trigger.isBodyActive = false
		-- 			end
		-- 		})
		-- 	end
		-- })

		--Triggers the Boss Fight
		if (bossStrategy.activeStrategy == 0) then
			event.contact.isEnabled = true
			transition.to(trigger, {time = 0, 
				onComplete = function()
					strategy:startFight()
				end
			})
			
			-- Closes the area of the fight
			trigger.walls = util.createWalls(game.map)
		end
	end

	return strategy
end

return bossStrategy