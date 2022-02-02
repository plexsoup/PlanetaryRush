extends Node2D

# Declare member variables here. Examples:
var FleetPath : Path2D
var FleetPathFollowNode : PathFollow2D
var NavTarget : Position2D
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
signal fleet_ready(fleet)
signal fleet_engaged(enemyFleet)
signal resumed_moving()
signal fleet_destroyed()
signal fleet_released()
signal request_navigation(callbackObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("ShipFleet.gd _ready() called. Creating a fleet. Hopefully once per user-draw-action")
	State = States.DEPLOYING
	Name = self.name

# called from Planet
func start(fleetPath, factionObj, numShips, shipScene, originPlanet, destinationPlanet, levelObj):
	#print("ShipPath start() called. Initializing a fleet. Hopefully once per user-draw-action")
	Level = levelObj
	FactionObj = factionObj
	FleetPath = fleetPath
	connect("fleet_destroyed", FleetPath, "_on_fleet_destroyed")
	
	request_navigation(fleetPath) # ask Path2D for a unique PathFollow2D node
	
	OriginPlanet = originPlanet
	DestinationPlanet = destinationPlanet
#	spawnShips(factionObj, numShips, shipScene, destinationPlanet)
	call_deferred("spawnShips", factionObj, numShips, shipScene, destinationPlanet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if State == States.MOVING:
#		if get_ship_count() == 0: # Error: this triggers before ships have been born!
#			State = States.DESTROYED
#			return
		if is_instance_valid(NavTarget):
			move_fleet_NavTarget(delta)
		else: # Why is the NavTarget gone?
			printerr("in Fleet.gd, NavTarget queued free while fleet was still moving.")
			die()
	elif State == States.ENGAGING_ENEMY:
		if battleIsOver(CurrentlyEngagedEnemyFleet):
			resumeMoving()
		# note, when ships die we get a signal. Each time one dies, we'll check to see if we're still needed.


#func get_ship_count():
#	return GetShipCount()
	
	
func battleIsOver(enemyFleet):
	var battleOver : bool = false
	if is_instance_valid(enemyFleet):
		if enemyFleet.GetShipCount() == 0:
			battleOver = true
	elif not is_instance_valid(enemyFleet):
		battleOver = true
	
	return battleOver


func die():
	emit_signal("fleet_destroyed", self)
	#notifyPathFleetDestroyed()
	State = States.FINISHED
	call_deferred("queue_free")
	
	
	
func move_fleet_NavTarget(delta):
	if is_instance_valid(FleetPathFollowNode):
		FleetPathFollowNode.set_offset(FleetPathFollowNode.get_offset() + delta * Speed * global.game_speed)
		# tell the path how far we've gotten, so the path can remove the line behind us
		
		if State == States.MOVING:
			if FleetPathFollowNode.get_unit_offset() > 0.98:
				# move the fleet somewhere else so the path can can queue_free
				# send the ships home
				State = States.WAITING # gets changed again in release_fleet()
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
	#print("Fleet.gd release_fleet() State == " + States.keys()[State])
	if State == States.WAITING:
		var nearestPlanet = get_closest_friendly_planet(NavTarget.get_global_position())
		for ship in $ShipsContainer.get_children():
			notifyShipItsReleased(ship, nearestPlanet)
		notifyPathFleetReleased()
		#print("Fleet.gd NavTarget is " + str(NavTarget) + " " + NavTarget.name)
		if NavTarget.is_class("Position2D"):
			FleetPathFollowNode.call_deferred("queue_free")
		State = States.FINISHED # just because the fleet is released from the path, doesn't mean the fleet is finished.. merely that they've completed their intended path



func get_closest_friendly_planet(pos):
	# this code is a bit of a mess as of Jan 2, 2022
	var nearestFriendly
	var nearestNeutral
	if is_instance_valid(FactionObj):
		nearestFriendly = FactionObj.get_nearest_planet(pos)
		nearestNeutral = Level.PlanetContainer.get_nearest_faction_planet(null, pos)

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
	# this needs a state check. Level may be ending
	if Level.State != Level.States.PLAYING:
		return
	else:
		for i in range(numShips):
			var shipNode = shipScene.instance()
			$ShipsContainer.add_child(shipNode) # why does this give errors sometimes?
			
			shipNode.start(self, factionObj, NavTarget, OriginPlanet, destinationPlanet, Level)
			# stick to local coords for this
			shipNode.set_position(Vector2(rand_range(-50, 50), rand_range(-50, 50)))

			# added the next line so ships orient themselves toward the cursor.
			shipNode.set_rotation(shipNode.get_angle_to(factionObj.CursorObj.get_global_position()))
			CurrentShips.push_back(shipNode)

		notifyPathFleetReady()



#func countAliveShips(): # may not need this anymore.. we maintain an array of live ships: CurrentShips
#	var numAlive = 0
#	var ships = GetShips()
#	for ship in ships:
#		if is_instance_valid(ship) and ship.IsAlive():
#			numAlive += 1
#	return numAlive
	

####################################################
# Global Functions, may be called from other objects

func GetShips():
	return $ShipsContainer.get_children()

func GetShipCount():
	return GetShips().size()
	# consider checking ship.IsAlive() before you assume it's alive.



#################################################
# Outbound Signals

func notifyShipItsReleased(shipObj, nearestPlanet):
	if is_instance_valid(shipObj):
		connect("ship_released", shipObj, "_on_fleet_released_ship")
		emit_signal("ship_released", nearestPlanet)
		disconnect("ship_released", shipObj, "_on_fleet_released_ship")

func notifyPathFleetReady():
	return # path doesn't care
	
#	connect( "fleet_ready", FleetPath, "_on_fleet_ready")
#	emit_signal("fleet_ready", self)
#	disconnect( "fleet_ready", FleetPath, "_on_fleet_ready")

#func notifyPathFleetDestroyed():
#	if is_instance_valid(FleetPath):
#		connect("fleet_destroyed", FleetPath, "_on_fleet_destroyed")
#		emit_signal("fleet_destroyed")
#		disconnect("fleet_destroyed", FleetPath, "_on_fleet_destroyed")




func notifyPathFleetReleased():
	if is_instance_valid(FleetPath):
		connect("fleet_released", FleetPath, "_on_fleet_released")
		emit_signal("fleet_released", self, self.FleetPathFollowNode)
		disconnect("fleet_released", FleetPath, "_on_fleet_released")

func request_navigation(path):
	connect("request_navigation", path, "_on_fleet_requests_navigation")
	emit_signal("request_navigation", self)
	disconnect("request_navigation", path, "_on_fleet_requests_navigation")


#################################################
# Incoming Signals

func _on_navigation_received(pathFollowNode : PathFollow2D):
	FleetPathFollowNode = pathFollowNode
	NavTarget = pathFollowNode.get_node("FleetTarget")
	connect("fleet_destroyed", FleetPathFollowNode, "_on_fleet_destroyed")
	State = States.MOVING
	
	
func _on_ship_destroyed(shipObj):
	CurrentShips.erase(shipObj)
	if CurrentShips.size() == 0:
		die()

func _on_NavMarker_encountered_enemy(enemyFleet):
	# where does this signal originate?
	if is_instance_valid(enemyFleet):
		initiateDogfight(enemyFleet)
	
#func _on_ship_destroyed(shipObj):
#	# if we have no ships left, we have no reason to live.
#
#	if countAliveShips() == 0:
#		die() # die will notify the path that the fleet was destroyed.
