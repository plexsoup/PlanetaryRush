extends Node2D

# Declare member variables here. Examples:
var FleetPath : PathFollow2D
var NavTarget
var Speed : float = 160.0 # try to keep the navTarget just a bit faster than the ships
var FactionObj : Node2D
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
func start(fleetPath, factionObj, numShips, shipScene, originPlanet):
	FactionObj = factionObj
	FleetPath = fleetPath
	NavTarget = FleetPath.get_node("FleetTarget")
	OriginPlanet = originPlanet
	State = States.MOVING
	addShips(factionObj, numShips, shipScene)


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
	var nearestFriendly = FactionObj.get_nearest_planet(pos)
	var nearestNeutral = global.NeutralFactionObj.get_nearest_planet(pos)

	# might want to change this to search for the nearest dead neutral (1 or 0 units present)
	var friendlyPos = nearestFriendly.get_global_position()
	var neutralPos = nearestNeutral.get_global_position()
	if pos.distance_squared_to(friendlyPos) < pos.distance_squared_to(neutralPos):
		print("fleet.gd found closest friendly planet")
		return nearestFriendly
	else:
		return nearestNeutral
	


func addShips(factionObj, numShips, shipScene):
	for i in range(numShips):
		var shipNode = shipScene.instance()
		$ShipsContainer.add_child(shipNode)
		shipNode.start(factionObj, NavTarget, OriginPlanet)
		# stick to local coords for this
		shipNode.set_position(Vector2(rand_range(-50, 50), rand_range(-50, 50)))

		# added the next line so ships orient themselves toward the cursor.
		shipNode.set_rotation(shipNode.get_angle_to(factionObj.CursorObj.get_global_position()))
	

