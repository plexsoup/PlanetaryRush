extends Node2D

# Declare member variables here. Examples:
var FleetPath : Path2D
var FleetPathFollowNode : PathFollow2D
var NavTarget
var Speed : float = 160.0 # try to keep the navTarget just a bit faster than the ships
var FactionObj : Node2D
var OriginPlanet
var DestinationPlanet
var Name : String
var Level : Node2D

var CurrentlyEngagedEnemyFleet = null

enum States { DEPLOYING, MOVING, ENGAGING_ENEMY, WAITING, FINISHED, DESTROYED }
var State = States.DEPLOYING
var CurrentShips = []

signal ship_released()
signal fleet_engaged(enemyFleet)
signal resumed_moving()
signal fleet_destroyed()
signal fleet_released()

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.DEPLOYING
	Name = self.name

# called from Planet
func start(fleetPath, factionObj, numShips, shipScene, originPlanet, destinationPlanet, levelObj):
	Level = levelObj
	FactionObj = factionObj
	FleetPath = fleetPath
	FleetPathFollowNode = fleetPath.get_node("PathFollow2D") # this is fragile
	NavTarget = FleetPathFollowNode.get_node("FleetTarget")
	OriginPlanet = originPlanet
	DestinationPlanet = destinationPlanet
	State = States.MOVING
	spawnShips(factionObj, numShips, shipScene, destinationPlanet)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if allShipsAreDead(): # Why is this fleet still alive?
		State = States.DESTROYED
		return

		
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


func die():
	notifyPathFleetDestroyed()
	State = States.FINISHED
	call_deferred("queue_free")
	
	
	
func move_fleet_NavTarget(delta):
	if is_instance_valid(FleetPathFollowNode):
		FleetPathFollowNode.set_offset(FleetPathFollowNode.get_offset() + delta * Speed * global.game_speed)
		# tell the path how far we've gotten, so the path can remove the line behind us
		
		
		if FleetPathFollowNode.get_unit_offset() > 0.98:
			# move the fleet somewhere else so the path can can queue_free
			# send the ships home
			State = States.WAITING
			#yield(get_tree().create_timer(1.0), "timeout")
			release_fleet()


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
		



func release_fleet():
	#let the ships return to the nearest planet, at their own discretion
	
	for ship in $ShipsContainer.get_children():
		ship.NavTarget = get_closest_friendly_planet(ship.get_global_position())
		
		notifyShipItsReleased(ship)
		
	notifyPathFleetReleased()
	State = States.FINISHED # just because the fleet is released from the path, doesn't mean the fleet is finished.. merely that they've completed their intended path



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
		shipNode.start(factionObj, NavTarget, OriginPlanet, destinationPlanet, Level)
		# stick to local coords for this
		shipNode.set_position(Vector2(rand_range(-50, 50), rand_range(-50, 50)))

		# added the next line so ships orient themselves toward the cursor.
		shipNode.set_rotation(shipNode.get_angle_to(factionObj.CursorObj.get_global_position()))

func countAliveShips(): # may not need this anymore.. we maintain an array of live ships: CurrentShips
	var numAlive = 0
	var ships = GetShips()
	for ship in ships:
		if is_instance_valid(ship) and ship.IsAlive():
			numAlive += 1
	return numAlive
	

####################################################
# Global Functions, may be called from other objects

func GetShips():
	return $ShipsContainer.get_children()

func GetShipCount():
	return GetShips().size()



#################################################
# Outbound Signals

func notifyShipItsReleased(shipObj):
	if is_instance_valid(shipObj):
		connect("ship_released", shipObj, "_on_fleet_released_ship")
		emit_signal("ship_released")
		disconnect("ship_released", shipObj, "_on_fleet_released_ship")

func notifyPathFleetDestroyed():
	if is_instance_valid(FleetPath):
		connect("fleet_destroyed", FleetPath, "_on_fleet_destroyed")
		emit_signal("fleet_destroyed")
		disconnect("fleet_destroyed", FleetPath, "_on_fleet_destroyed")

func notifyPathFleetReleased():
	if is_instance_valid(FleetPath):
		connect("fleet_released", FleetPath, "_on_fleet_released")
		emit_signal("fleet_released")
		disconnect("fleet_released", FleetPath, "_on_fleet_released")

	
	
#################################################
# Incoming Signals

func _on_ship_created(shipObj):
	if not CurrentShips.has(shipObj):
		CurrentShips.push_back(shipObj)
	else:
		printerr("Ship is trying to register itself with fleet, but it's already registered.")
	
func _on_ship_destroyed(shipObj):
	CurrentShips.erase(shipObj)
	if CurrentShips.size() == 0:
		die()

func _on_ShipPath_encountered_enemy(enemyFleetObj):
	if is_instance_valid(enemyFleetObj):
		initiateDogfight(enemyFleetObj)
	
#func _on_ship_destroyed(shipObj):
#	# if we have no ships left, we have no reason to live.
#
#	if countAliveShips() == 0:
#		die() # die will notify the path that the fleet was destroyed.
