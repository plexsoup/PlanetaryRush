extends Node2D

# Declare member variables here. Examples:
var FleetPath : PathFollow2D
var NavTarget
var Speed : float = 160.0 # try to keep the navTarget just a bit faster than the ships
var FactionObj : Node2D
var OriginPlanet
var DestinationPlanet
var Name : String

var CurrentlyEngagedEnemyFleet = null

enum States { DEPLOYING, MOVING, ENGAGING_ENEMY, WAITING, FINISHED }
var State = States.DEPLOYING

signal ship_released()
signal fleet_engaged(enemyFleet)
signal resumed_moving()

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.DEPLOYING
	Name = self.name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.MOVING:
		if is_instance_valid(NavTarget):
			move_fleet_NavTarget(delta)
		else: # Why is the NavTarget gone?
			printerr("in Fleet.gd, NavTarget queued free while fleet was still moving.")
			die()
	elif State == States.ENGAGING_ENEMY:
		if allShipsAreDead():
			die()
		if battleIsOver(CurrentlyEngagedEnemyFleet):
			resumeMoving()


func allShipsAreDead():
	return (GetShipCount() == 0)
	
	
func battleIsOver(enemyFleet):
	var battleOver : bool = false
	if is_instance_valid(enemyFleet):
		if enemyFleet.allShipsAreDead():
			battleOver = true
	elif not is_instance_valid(enemyFleet):
		battleOver = true
	
	return battleOver

# called from Planet
func start(fleetPath, factionObj, numShips, shipScene, originPlanet, destinationPlanet):
	FactionObj = factionObj
	FleetPath = fleetPath
	NavTarget = FleetPath.get_node("FleetTarget")
	OriginPlanet = originPlanet
	DestinationPlanet = destinationPlanet
	State = States.MOVING
	spawnShips(factionObj, numShips, shipScene, destinationPlanet)

func die():
	remove_path()
	State = States.FINISHED
	call_deferred("queue_free")
	
	
	
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


#
#	return nearestEnemyFleet

func GetCurrentPosition():
	return NavTarget.get_global_position()
	
func initiateDogfight(enemyFleetObj):
	# notify each ship they're free to battle.
	# pause the NavTarget on ShipPath until the battle is over?
	
	State = States.ENGAGING_ENEMY
	CurrentlyEngagedEnemyFleet = enemyFleetObj
	
	for shipObj in $ShipsContainer.get_children():
		connect("fleet_engaged", shipObj, "_on_fleet_engaged_enemy")
		emit_signal("fleet_engaged", enemyFleetObj)
		disconnect("fleet_engaged", shipObj, "_on_fleet_engaged_enemy")

func resumeMoving():
	State = States.MOVING
	CurrentlyEngagedEnemyFleet = null
	for ship in GetShips():
		connect("resumed_moving", ship, "_on_fleet_resumed_moving")
		emit_signal("resumed_moving")
		disconnect("resumed_moving", ship, "_on_fleet_resumed_moving")
		

func GetShips():
	return $ShipsContainer.get_children()

func GetShipCount():
	return GetShips().size()

func release_fleet():
	#let the ships return to the nearest planet, at their own discretion
	
	# spawn a position2D node at the planet
	# tell each ship (child) to follow that
	#FleetPath.set_offset(0)
	for ship in $ShipsContainer.get_children():
		ship.NavTarget = get_closest_friendly_planet(ship.get_global_position())
		
		notifyShipItsReleased(ship)
		
		
	remove_path()
	State = States.FINISHED

func notifyShipItsReleased(shipObj):
	#ship.State = ship.States.RETURNING	
	connect("ship_released", shipObj, "_on_fleet_released_ship")
	emit_signal("ship_released")
	disconnect("ship_released", shipObj, "_on_fleet_released_ship")


func remove_path():
	if FleetPath != null and is_instance_valid(FleetPath):
		FleetPath.get_parent().end()

func get_closest_friendly_planet(pos):
	# this code is a bit of a mess as of Jan 2, 2022
	var nearestFriendly
	var nearestNeutral
	if is_instance_valid(FactionObj):
		nearestFriendly = FactionObj.get_nearest_planet(pos)
	if is_instance_valid(global.NeutralFactionObj):
		nearestNeutral = global.NeutralFactionObj.get_nearest_planet(pos)

	# might want to change this 
	# to search for the nearest 'dead' neutral planet
	# which has (1 or 0 units present)
	if nearestFriendly == null and nearestNeutral == null:
		printerr("Fleet can't find a nearby friendly planet")
		return
	else: # one of them must be valid
		var friendlyPos : Vector2
		var neutralPos : Vector2
		if is_instance_valid(nearestFriendly):
			friendlyPos = nearestFriendly.get_global_position()
		if is_instance_valid(nearestNeutral):
			neutralPos = nearestNeutral.get_global_position()
		if is_instance_valid(nearestNeutral) and is_instance_valid(nearestFriendly):
			if pos.distance_squared_to(friendlyPos) < pos.distance_squared_to(neutralPos):
				return nearestFriendly
			else:
				return nearestNeutral
		elif is_instance_valid(nearestFriendly):
			return nearestFriendly
		elif is_instance_valid(nearestNeutral):
			return nearestNeutral
	


func spawnShips(factionObj, numShips, shipScene, destinationPlanet):
	for i in range(numShips):
		var shipNode = shipScene.instance()
		$ShipsContainer.add_child(shipNode)
		shipNode.start(factionObj, NavTarget, OriginPlanet, destinationPlanet)
		# stick to local coords for this
		shipNode.set_position(Vector2(rand_range(-50, 50), rand_range(-50, 50)))

		# added the next line so ships orient themselves toward the cursor.
		shipNode.set_rotation(shipNode.get_angle_to(factionObj.CursorObj.get_global_position()))
	

func _on_ShipPath_encountered_enemy(enemyFleetObj):
	if is_instance_valid(enemyFleetObj):
		initiateDogfight(enemyFleetObj)
	
