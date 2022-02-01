extends PathFollow2D

var Fleet
var FleetPath
var Level

signal encountered_enemy(fleet)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func end():
	#disconnect("encountered_enemy", Fleet, "_on_NavMarker_encountered_enemy")
	# you could use get_signal_list and get_signal_connection_list to clear all signals,
	# but they should disconnect on their own as part of the queue_free cleanup process
	
	queue_free()

func die():
	end()

func start(level, fleet, fleetPath):
	Level = Level
	Fleet = fleet
	FleetPath = fleetPath
	connect("encountered_enemy", Fleet, "_on_NavMarker_encountered_enemy")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_fleet_destroyed(fleet):
	if fleet == Fleet:
		die()

func _on_FleetDogfightZone_area_entered(area):
	if area.is_in_group("NavMarkers"):
		var enemyFleet = area.owner.Fleet
		if is_instance_valid(enemyFleet) and enemyFleet != Fleet:
			if enemyFleet.FactionObj != Fleet.FactionObj:
				emit_signal("encountered_enemy", enemyFleet)

