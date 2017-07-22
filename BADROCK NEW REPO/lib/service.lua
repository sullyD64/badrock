local json = require( "json" )
local defaultData = require("defaultData")

-- Crea il file "userData.json" in una directory dell'app
local filePath = system.pathForFile( "userData.json", system.DocumentsDirectory )
local service = {}

function service.loadData()
	local data = {}

	-- Apre il file nella directory sopra indicata, in modalità lettura
	local file = io.open( filePath, "r" )

	if file then
		-- Legge tutto il file e lo mette nella variabile "contents"
		local contents = file:read( "*a" )
		-- Chiude il file
		io.close( file )
		-- Mette in "defaultData" la tabella decodificata dal json
		data = json.decode( contents )

		--- [commenta quando hai fatto i test] ---
		-- print("userData.json contains:")
		-- util.print_r(data)
		------------------------------------------
	else 
		data = defaultData
	end

	return data
end

function service.saveData()
	-- Apre il file in modalità scrittura
	local file = io.open( filePath, "w" )

	if file then
		-- Scrive il file con una versione codificata di myData
		file:write( json.encode( myData ) )
		-- chiude il file
		io.close( file )
	end
end

function service.resetData()
	--apre il file in modalità scrittura
	local file = io.open( filePath, "w" )
	
	if file then
		-- scrive il file con una versione codificata di defaultData
		file:write( json.encode( defaultData ) )
		-- chiude il file
		io.close( file )
	end
end


return service