extends Container


# Declare member variables here. Examples:
onready var FactionProgressBar = $ProgressBar
onready var FactionNameLabel = $Nameplate/HBox/Name
onready var FactionStatusLabel = $Nameplate/HBox/Status
var FactionObj : Node2D
var Level : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(levelObj, factionObj):
	Level = levelObj
	FactionObj = factionObj
	FactionNameLabel.set_text(factionObj.name)
	FactionProgressBar.set_self_modulate(FactionObj.fColor)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(Level) and is_instance_valid(FactionObj):
		if global.Ticks % 100 == 0:
			
			var factionPlanets = FactionObj.CurrentPlanetList.size()
			var totalPlanets = Level.PlanetContainer.get_child_count()
			FactionNameLabel.set_text(FactionObj.name)
			
			var statusStr : String = FactionObj.States.keys()[FactionObj.State]
			if statusStr == "DEAD":
				FactionStatusLabel.set_text(statusStr)
			else: 
				FactionStatusLabel.set_text("")
			
			FactionProgressBar.set_value(float(factionPlanets)/max(float(totalPlanets)*100, 1))
			FactionProgressBar.update()
		

