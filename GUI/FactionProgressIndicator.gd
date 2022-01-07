extends HSplitContainer


# Declare member variables here. Examples:
onready var ProgressBar = $ProgressBar
onready var Label = $Label
var FactionObj : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(factionObj):
	FactionObj = factionObj
	Label.set_text(factionObj.Name)
	ProgressBar.set_self_modulate(FactionObj.fColor)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.Ticks % 100 == 0:
		var level = global.Main.CurrentLevel
		var factionPlanets = FactionObj.CurrentPlanetList.size()
		var totalPlanets = level.PlanetContainer.get_child_count()
		if factionPlanets == 0:
			Label.set_text("Dead")
		else:
			Label.set_text(FactionObj.Name)
		ProgressBar.set_value(float(factionPlanets)/float(totalPlanets)*100)
		ProgressBar.update()
		
