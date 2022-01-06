"""
Ships will:
	detect collisions with enemies
	try and avoid peers
	attack planets

"""

extends Area2D

var VelocityVectors:Array = []
var Speed : float = 150.0
var TurnSpeed : float = 10.0
var FactionObj : Node2D
var IsHumanPlayer: bool = false
var MyFleet: Node2D
export var BulletScene : PackedScene
export var DefaultFuelTimeLimit : float = 30.0 # seconds
export var Health = 1
export var HullStrength = 1 # amount of damage to deal when you hit another ship.
# export var Shields = 0

var NavTarget # could be Position2D (FleetTarget) or StaticBody2D (planet)
var OriginPlanet : StaticBody2D
var DestinationPlanet : StaticBody2D
var TimeElapsed : float = 0
var Level
var CurrentEnemyFleetEngaged = null
var CurrentShipTargeted = null

var ShipToGroundWeapons = []
var ShipToShipWeapons = []

onready var FiringArcCollisionShape = $FiringArc/CollisionPolygon2D

var VectorToGoal # for debug drawing

enum States { ADVANCING, RETURNING, ENGAGING_ENEMY, BOMBARDING, DEAD }
var State = States.ADVANCING

signal created(shipObj)
signal destroyed(shipObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ships")
	


# Called by fleet
func start(factionObj, navTarget, originPlanet, destinationPlanet):
	Level = global.Main.CurrentLevel
	FactionObj = factionObj
	registerShipWithFaction()
	if FactionObj.IsLocalHumanPlayer:
		IsHumanPlayer = true
	set_color(factionObj)
	OriginPlanet = originPlanet
	DestinationPlanet = destinationPlanet
	$Sprite.set_frame(factionObj.Number)
	MyFleet = get_parent().get_parent() # each fleet has a ShipsContainer node
	NavTarget = navTarget # FleetTarget
	startFuelTimer(DefaultFuelTimeLimit)
	initializeWeapons()
	
func initializeWeapons():
	for weapon in $Weapons.get_children():
		if weapon.ShipToGround == true:
			ShipToGroundWeapons.push_back(weapon)
		if weapon.ShipToShip == true:
			ShipToShipWeapons.push_back(weapon)

func startFuelTimer(durationInSeconds):
	# adjusted for game_speed
	$Engines/FuelLimitTimer.set_wait_time(durationInSeconds / max(global.game_speed, 0.0001))
	$Engines/FuelLimitTimer.start()


func registerShipWithFaction():
	connect("created", FactionObj, "_on_ship_created")
	emit_signal("created", self)
	disconnect("created", FactionObj, "_on_ship_created")


func deregisterShipWithFaction():
	connect("destroyed", FactionObj, "_on_ship_destroyed")
	emit_signal("destroyed", self)
	disconnect("destroyed", FactionObj, "_on_ship_destroyed")
	



func set_color(factionObj):
	$Sprite.set_self_modulate(factionObj.fColor)
	$Weapons.set_modulate(factionObj.fColor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.DEAD or Level.State != Level.States.PLAYING:
		return
	else:
		TimeElapsed += delta
		collectVelocityVectors()
		move(delta)
		
		if global.Debug:
			$StatusLabel.text = States.keys()[State]
			update() # refreshes _draw()
		
		if State == States.RETURNING and planet_within_landing_distance(NavTarget):
			land(NavTarget)
	
func planet_within_landing_distance(planetObj):
	if planetObj == null or not is_instance_valid(planetObj): 
		return
	else:
		var closeEnough : bool = false
		var myPos = get_global_position()
		var targetPos = NavTarget.get_global_position()
		var landingDistance = 80.0
		#if utils.WithinFuzzyProximity(myPos, targetPos, landingDistance, 0.1):
		if utils.WithinFuzzyProximity(self, planetObj, landingDistance, 0.1):
			closeEnough = true
		return closeEnough


func move(delta):
	var vectorToGoal = averageVelocityVectors()
	VectorToGoal = vectorToGoal
	
	var myPos = get_global_position()

	turnTowardsTarget(vectorToGoal, delta)

	var fwd = Vector2.RIGHT.rotated(rotation)
	set_global_position(myPos + fwd * delta * Speed * global.game_speed)


func turnTowardsTarget(vectorToGoal, delta):
	var myRot = get_global_rotation()
	var myFwdVector = Vector2.RIGHT.rotated(myRot)
	var angleToGoal = myFwdVector.angle_to(vectorToGoal)
	var lerpedRot = lerp_angle(myRot, angleToGoal, 0.8)
	
	self.rotate(angleToGoal * TurnSpeed * delta * global.game_speed)
	#self.rotate( lerpedRot * TurnSpeed * delta * global.game_speed )
	# why does lerpedRot send some of them off to the left?


func collectVelocityVectors():
	VelocityVectors = []
	VelocityVectors.push_back(get_peer_avoidance_vector())
	VelocityVectors.push_back(get_planet_avoidance_vector(NavTarget))
	if State == States.ADVANCING:
		VelocityVectors.push_back(get_fleet_path_vector())
	elif State == States.ENGAGING_ENEMY:
		VelocityVectors.push_back(get_dogfighting_vector())
	elif State == States.RETURNING:
		VelocityVectors.push_back(get_vector_toward_planet(DestinationPlanet))

	# later, add:
		# threat_pursuit_vector
		# planet_attack_vector
		# flanking_vector
		# etc.



func averageVelocityVectors():
	var returnVec = Vector2.ZERO
	for vector in VelocityVectors:
		returnVec += vector
	returnVec = returnVec.normalized()
	return returnVec

func get_dogfighting_vector():
	# TODO
	# figure out how to find nearby fleets or ships.
	# then figure out how to attack them
	# try and predict where they're going, get to their flank, avoid their front
	# throw in some randomness or attack patterns
	
	# note: level has a fleet container and each fleet has a ships container.
	# it might be more practical for fleet vs fleet combat, than ship vs ship.
	# impractical for every ship to look for every other ship.
	
	var dogfightingVector = Vector2.ZERO
	# turn toward the nearest enemy ship and shoot
	if is_instance_valid(CurrentEnemyFleetEngaged):
		var enemyShips = CurrentEnemyFleetEngaged.GetShips()
		CurrentShipTargeted = utils.GetRandElement(enemyShips)
		if is_instance_valid(CurrentShipTargeted):
			var targetPos = CurrentShipTargeted.get_global_position()
			var myPos = self.get_global_position()
			dogfightingVector = (targetPos - myPos).normalized()
	else:
		printerr("ship thinks it's Engaging enemy, but the ship it targeted doesn't exist")
	return dogfightingVector

func get_fleet_path_vector():
	var returnVec = Vector2.ZERO
	var myPos = get_global_position()
	if NavTarget != null and is_instance_valid(NavTarget):
		var targetPos = NavTarget.get_global_position()
		returnVec += (targetPos - myPos).normalized()
	return returnVec

func get_vector_toward_planet(planetObj):
	var returnVec = Vector2.ZERO
	var myPos = get_global_position()
	if is_instance_valid(planetObj):
		var targetPos = planetObj.get_global_position()
		returnVec += (targetPos - myPos).normalized()
	return returnVec
	

func get_planet_avoidance_vector(destinationPlanet):
	# find the nearest planet, and add a vector away from it if it's too close
	var level = global.Main.CurrentLevel
	
	var returnVec = Vector2(0,0)
	var myPos = get_global_position()
	var avoidDistance = 200.0
	
	var nearestPlanet = level.PlanetContainer.get_nearest_planet(myPos)
	if is_instance_valid(nearestPlanet):
		if nearestPlanet != destinationPlanet: # you're allowed to land on the destination
			var planetPos = nearestPlanet.get_global_position()
			if utils.WithinFuzzyProximity(self, destinationPlanet, avoidDistance, 0.1):
				returnVec += (myPos - planetPos).normalized()
	else:
		# It's ok, there's no planets to worry about within minimum distance_squared.
		# but it might mean a ship is flying off into the sunset (they're not supposed to do that).
		pass
	return returnVec
	
func get_peer_avoidance_vector():
	# only avoids ships in the current fleet
	var returnVec = Vector2(0,0)
	var myPos = get_global_position()
	var avoidDistance = 35.0
	
	for ship in get_parent().get_children():
		var shipPos = ship.get_global_position()
		if ship != self:
			if utils.WithinFuzzyProximity(self, ship, avoidDistance, 0.1):
				returnVec -= shipPos - myPos
	returnVec = returnVec.normalized()
	return returnVec

func die():
	deregisterShipWithFaction()
	call_deferred("disable_collision_shapes")
	State = States.DEAD
	
	var animPlayer = $death/AnimationPlayer
	animPlayer.play("explode")
	
	yield(animPlayer, "animation_finished")
	#yield(get_tree().create_timer(0.95), "timeout")
	if is_instance_valid(FactionObj):
		FactionObj.DeregisterShip(self)
	call_deferred("queue_free")

func disable_collision_shapes(): # for death
	$CollisionShape2D.call_deferred("set_disabled", true)
	FiringArcCollisionShape.call_deferred("set_disabled", true)

func disable_firingArc():
	FiringArcCollisionShape.call_deferred("set_disabled", true)
	
func enable_firingArc():
	FiringArcCollisionShape.call_deferred("set_disabled", false)

func fireOnPlanet(planet):
	if planet.FactionObj != self.FactionObj:
		if planet == DestinationPlanet:
			for weapon in ShipToGroundWeapons:
				if weapon.WeaponStatus == weapon.Status.READY:
					weapon.CommenceFiring()
					disable_firingArc()



func _on_FiringArc_area_entered(area):
	if area.is_in_group("ships") and area.FactionObj != FactionObj:

		for weapon in ShipToShipWeapons:
			if weapon.WeaponStatus == weapon.Status.READY:
				weapon.CommenceFiring()
				disable_firingArc()
			# TODO: what happens if the weapons aren't ready? should it circle for another pass?
		

func _on_FiringArc_body_entered(body):
	# shoot planets, but not friendly ones
		
	if body.is_in_group("planets"):
		fireOnPlanet(body)
		

func _on_hit(damage, factionObj): # is factionObj the attacker or defender?
	Health -= damage
	if Health <= 0:
		die()
		
func _draw():
	if global.Debug:
		var myPos = get_global_position()
		# azure = direction to target
		draw_line(to_local(myPos), to_local(VectorToGoal*20 + myPos), Color.azure, 3, true)
		# green = direction of Vector2.RIGHT
		draw_line(to_local(myPos), to_local(Vector2.RIGHT * 20 + myPos), Color.green, 3, true)
		# red = direction of self.rotation
		draw_line(to_local(myPos), to_local(Vector2.RIGHT.rotated(self.rotation) * 20 + myPos), Color.red, 3, true)
	
func land(planet):
	planet._on_ship_landed(1, FactionObj)
	die()
	



func _on_Ship_body_entered(body):
	#Hmm. this only seems to happen for the initial origin planet.
	# land_on_nearby_planet doesn't even use collision shapes

#	if body.is_in_group("planets"):
#		var planet = body
#		if TimeElapsed > 2.0 / max(global.game_speed,0.1): # otherwise fires too quickly. need to check if it's our planet of origin
#			print("ship.gd Does this event (_on_Ship_body_entered ) ever happen?")
#			land(planet)
#			print("Ship.gd - landing now")
	pass


func _on_SwapMagazineTimer_timeout(): #Weapons say they're ready again
	enable_firingArc()
	
func _on_fleet_released_ship():
	State = States.RETURNING



func _on_FuelLimitTimer_timeout():
	# you've been flying around for too long.. disappear now
	die() # die function also deregisters ship with faction
	print("FYI: ship.gd is killing another ship due to fuel limit. Ideally this wouldn't happen very often. It might indicate a problem with ships finding a landing site.")

func _on_fleet_engaged_enemy(enemyFleetObj):
	if is_instance_valid(enemyFleetObj):
		State = States.ENGAGING_ENEMY
		CurrentEnemyFleetEngaged = enemyFleetObj

func _on_fleet_resumed_moving():
	State = States.ADVANCING
	CurrentEnemyFleetEngaged = null


func _on_Ship_area_entered(area):
	# refactor ideas: choose one method to verify that it's another ship.

	var enemyShip
	if area.is_in_group("ships") and area.FactionObj != self.FactionObj:
		enemyShip = area
	else:
		return
	
	if enemyShip.has_method("_on_hit"):
		enemyShip._on_hit(HullStrength, FactionObj)

