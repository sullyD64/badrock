-----------------------------------------------------------------------------------------
--
-- enemies.lua
--
-----------------------------------------------------------------------------------------
local physics =  require ( "physics" )
local items = require ( "items" )
local enemies= require("enemies")

local bosses = {}

	bosses.list = {
	--1
		{
		type = "bossliv1",
		lives = 1,
		bounce = 0,
		friction = 1.0,
		density = 1.0,
		image = "sprites/robot.png",
		height = 40,
		width = 40,
		speed=0
		},

}

-- Create a new Enemy with his attributes and image if we pass (as a parameter) an oggettoOrigine from Tiled
function bosses.createBoss( boss , type )
		local b = nil
		for k, v in pairs(bosses.list) do
			if (v.type == type) then
				b = v
				break
			end
		end
		boss = display.newImageRect (b.image , b.width, b.height)
		boss.type = type
		boss.lives = b.lives
		boss.isEnemy = true
		boss.isTargettable = true
		physics.addBody( boss, { density = b.density, friction = b.friction, bounce = b.bounce} )
		return boss
end

--mancano le lifeicon
function gestisciVita()
local lifeIcons = {}
local lives = 5
local maxLives = 5
lifeBar[0] = display.newImage("lifeicon0.png")
lifeBar[1] = display.newImage("lifeicon1.png")
lifeBar[2] = display.newImage("lifeicon2.png")
lifeBar[3] = display.newImage("lifeicon3.png")
lifeBar[4] = display.newImage("lifeicon4.png")
lifeBar[5] = display.newImage("lifeicon5.png")
local i
for i = 1, maxLives do
    lifeBar[i].x = 10
    lifeBar[i].y = 30
    lifeBar[i].isVisible = false
end
lifeBar[lives].isVisible = true

--aggiorna
if lives &gt; 0 then
    lifeBar[lives].isVisible = false
    lives = lives - 1
    lifeBar[lives].isVisible = true
end
end

local function textListener( event )
 
    if ( event.phase == "began" ) then
        
 
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
            
    end
end

--inizia un breve dialogo con il nemico, testo da mettere in un array per poterne scorrere gli elementi
function presentati()
-- defaultBox = native.newTextBox( display.contentCenterX, display.contentCenterY, 280, 140 )
-- defaultBox.text = "Well.. I didn't expect you would have survived"
local textField = native.newTextField( display.contentCenterX, display.contentCenterY, 260, 100 )
textField:setTextColor( 0.8, 0.8, 0.8 )
textField.size=15
textField.text="Well.. I didn't expect you would have survived"
--background del textbox trasparente, non supportato da emulatore su windows
textField.hasBackground = false
--cliccando si scorre il testo più velocemente
defaultBox:addEventListener( "touch", textListener )
end

--nella fase 1 si presenta, lancia missili e salta normalmente
--PER ORA E' PARAMETRICA
local function fase1
	if(boss) then
		presentati()
		--se si è presentato, inizia la battaglia
		lanciaMissile(boss)
		lanciaMissile(boss)
		lanciaMissile(boss)
		schiacciata(boss)
		--ecc.
	end
end

--nella fase 2 lancia missili e salta velocemente
local function fase2
end

function crea(oggettoDaCreare,oggettoOrigine)
			oggettoDaCreare.x=oggettoOrigine.x-100
			oggettoDaCreare.y=oggettoOrigine.y
			-- oggettoDaCreare.xScale=-1
			-- oggettoDaCreare.yScale=-1
			-- oggettoDaCreare.rotation=90
			oggettoDaCreare.bodyType="static"
			physics.addBody(oggettoDaCreare, {density = 1, friction = 1, bounce = 0.5})
			--oggettoDaCreare.gravityScale=0.05
			oggettoDaCreare.isSensor=true
			
			--oggettoDaCreare.speed=1
			game.map:getTileLayer("entities"):addoggettoOrigine( oggettoDaCreare )

end

function lancia(oggettoDaLanciare)
	local fx= game.steve.x-oggettoDaLanciare.x
	local fy= game.steve.y-oggettoDaLanciare.y
	--local count=0
	--if (count==0) then
	oggettoDaLanciare:applyLinearImpulse(fx/100,fy/100,oggettoDaLanciareLanciare.x,oggettoDaLanciare.y)
end

--lancia un oggettoDaCreare dalla posizione di oggettoOrigine
local function lanciaMissile(oggettoOrigine)
--oggettoOrigine= bosses.list[1]
oggettoLancio= display.newImageRect ("sprites/robot.png" , 10, 10)--da aggiornare sprite
if(oggettoOrigine.x and oggettoLancio.x) then
	crea(oggettoLancio,oggettoOrigine)
	oggettoLancio.isDanger=true
	lancia(oggettoLancio)
end
end

--funzione da richiamare al massimo 3 volte
local function schiacciata(boss)
boss:applyLinearImpulse( 60, 20, boss.x, boss.y )

--se è in aria, schiaccia
haSaltato=false
if(boss.y<game.steve.y) then
boss:applyLinearImpulse( 60, -10, boss.x, boss.y )
haSaltato=true
end
se ha saltato rimuove un pezzo di pavimento
if(haSaltato and boss.x) then

end
end
return bosses