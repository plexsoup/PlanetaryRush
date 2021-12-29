extends Node2D

# Declare member variables here. Examples:
var FleetPath : PathFollow2D
var NavTarget
var Speed : float = 160.0 # try to keep the navTarget just a bit faster than the ships
var Faction : int
var OriginPlanet
var Name : String

enum States { DEPLOYING, MOVING, WAITING, FINISHED }
var State = States.DEPLOYING

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.DEPLOYING
	Name = self.name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.MOVING:
		move_fleet_NavTarget(delta)

# called from Planet
func start(fleetPath, faction, numShips, shipScene, originPlanet):
	Faction = faction
	FleetPath = fleetPath
	NavTarget = FleetPath.get_node("FleetTarget")
	OriginPlanet = originPlanet
	State = States.MOVING
	addShips(faction, numShips, shipScene)
	
#AI will use regular start, just like the player
#func start_AI_fleet(faction, numShips, shipScene, originPlanet, destinationPlanet):
#	Faction = faction
#	FleetPath = null
#	NavTarget = destinationPlanet
#	OriginPlanet = originPlanet
#	State = States.MOVING
#	addShips(faction, numShips, shipScene)

func move_fleet_NavTarget(delta):
	if FleetPath != null and is_instance_valid(FleetPath):
		FleetPath.set_offset(FleetPath.get_offset() + delta * Speed * global.game_speed)
		# tell the path how far we've gotten, so the path can remove the line behind us
		
		
		if FleetPath.get_unit_offset() > 0.98:
			# move the fleet somewhere else so I can queue_free
			# send the ships home
			State = States.WAITING
			yield(get_tree().create_timer(1.0), "timeout")
			release_fleet()
	

func release_fleet():
	#let the ships return to the nearest planet, at their own discretion
	
	# spawn a position2D node at the planet
	# tell each ship (child) to follow that
	#FleetPath.set_offset(0)
	for ship in $ShipsContainer.get_children():
		ship.NavTarget = get_closest_friendly_planet(ship.get_global_position())
		ship.State = ship.States.RETURNING
	remove_path()
	State = States.FINISHED
		
func remove_path():
	if FleetPath != null and is_instance_valid(FleetPath):
		FleetPath.get_parent().end()

func get_closest_friendly_planet(pos):
	return global.planet_container.get_nearest_faction_planet(Faction, pos)

	
	


func addShips(faction, numShips, shipScene):
	#print(self.name, " addShips(", faction, ", ", numShips, " , ", shipScene, ")")
	for i in range(numShips):
		var shipNode = shipScene.instance()
		$ShipsContainer.add_child(shipNode)
		shipNode.start(faction, NavTarget, OriginPlanet)
		# stick to local coords for this
		shipNode.set_position(Vector2(rand_range(-50, 50), rand_range(-50, 50)))
		
	

