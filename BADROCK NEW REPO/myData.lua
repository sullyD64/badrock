local M = {}
M.maxLevels = 5
M.settings = {}
M.settings.currentLevel = 1
M.settings.unlockedLevels = 1
M.settings.soundOn = true
M.settings.musicOn = true
M.settings.levels = {}
M.settings.levels[1] = {}
M.settings.levels[1].stars = 0
M.settings.levels[1].score = 0
M.settings.levels[2] = {}
M.settings.levels[2].stars = 0
M.settings.levels[2].score = 0
M.settings.levels[3] = {}
M.settings.levels[3].stars = 0
M.settings.levels[3].score = 0
M.settings.levels[4] = {}
M.settings.levels[4].stars = 0
M.settings.levels[4].score = 0
M.settings.levels[5] = {}
M.settings.levels[5].stars = 0
M.settings.levels[5].score = 0
M.settings.goodPoints=5
M.settings.evilPoints=20
M.settings.skinNumber= 3
M.settings.selectedSkin=1
M.settings.skins = {}
M.settings.skins[1]= {}
M.settings.skins[1].unlocked = true
M.settings.skins[1].price = 0
M.settings.skins[1].type = "good"
M.settings.skins[1].sheet = visual.steveDefaultSprite
M.settings.skins[1].attackSheet = visual.steveDefaultAttack
M.settings.skins[2]={}
M.settings.skins[2].unlocked = false
M.settings.skins[2].price = 5
M.settings.skins[2].type = "good"
M.settings.skins[2].sheet = visual.steveSuperSprite
M.settings.skins[2].attackSheet = visual.steveSuperAttack
M.settings.skins[3]={}
M.settings.skins[3].unlocked = false
M.settings.skins[3].price = 20
M.settings.skins[3].type = "evil"
M.settings.skins[3].sheet = visual.steveDarkSprite
M.settings.skins[3].attackSheet = visualsteveDarkAttack
return M