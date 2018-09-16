classes = {}

classes.dimension = require("dimension")

classes.baseEntity = require("entities/base_entity")
	classes.pickable = require("entities/pickable") -- TODO: Plant?
		classes.soupCap = require("entities/soup_cap")
	classes.animal = require("entities/animal")
		classes.biped = require("entities/biped")
			classes.human = require("entities/human")
				classes.femalePlayer = require("entities/female_player")
				classes.malePlayer = require("entities/male_player")
				classes.foxSpirit = require("entities/fox_spirit")
				classes.ghostMaiden = require("entities/ghost_maiden")
	classes.chair = require("entities/chair")
		classes.woodenChair = require("entities/wooden_chair")
	classes.pot = require("entities/pot")
	classes.lamp = require("entities/lamp")
