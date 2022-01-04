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
var Health = 1
var NavTarget # could be Position2D (FleetTarget) or StaticBody2D (planet)
var OriginPlanet : StaticBody2D
var TimeElapsed : float = 0
var Ticks: int = 0
onready var FiringArcCollisionShape = $FiringArc/CollisionPolygon2D

var VectorToGoal # for debug drawing

enum States { ADVANCING, RETURNING, BOMBARDING, DEAD }
var State = States.ADVANCING

signal created(shipObj)
signal destroyed(shipObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ships")

# Called by fleet
func start(factionObj, navTarget, originPlanet):
	FactionObj = factionObj
	registerShipWithFaction()
	if FactionObj.IsLocalHumanPlayer:
		IsHumanPlayer = true
	set_color(factionObj)
	OriginPlanet = originPlanet
	$Sprite.set_frame(factionObj.Number)
	MyFleet = get_parent().get_parent() # each fleet has a ShipsContainer node
	NavTarget = navTarget # FleetTarget
	startFuelTimer(DefaultFuelTimeLimit)

func startFuelTimer(durationInSeconds):
	# adjusted for game_speed
	$Engines/FuelLimitTimer.set_wait_time(durationInSeconds / max(global.game_speed, 0.1))
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
	if State == States.DEAD:
		return
		
	TimeElapsed += delta
	Ticks += 1
	
	collectVelocityVectors()
	move(delta)
	
	$StatusLabel.text = States.keys()[State]
	
	update() # refreshes _draw()
	
	if State == States.RETURNING:
		# hack to prevent hovering around planets you never left
		land_on_nearby_planet()
	
func land_on_nearby_planet():
		#Why aren't we using collision shapes for this?

	if NavTarget == null: # ? why ?
		printerr("Ship.gd NavTarget == null in land_on_nearby_planet")
		die() # *** ? Huh? What's happening here?
	else:
		var myPos = get_global_position()
		var targetPos = NavTarget.get_global_position()
		var landingDistance = 80.0
		if myPos.distance_squared_to(targetPos) < landingDistance * landingDistance:
			land(NavTarget)


	
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
	VelocityVectors.push_back(get_fleet_path_vector())
	VelocityVectors.push_back(get_planet_avoidance_vector(NavTarget))
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


func get_fleet_path_vector():
	var returnVec = Vector2.ZERO
	var myPos = get_global_position()
	if NavTarget != null and is_instance_valid(NavTarget):
		var targetPos = NavTarget.get_global_position()
		returnVec += (targetPos - myPos).normalized()
	return returnVec

func get_planet_avoidance_vector(destinationPlanet):
	# find the nearest planet, and add a vector away from it if it's too close

	var returnVec = Vector2(0,0)
	var myPos = get_global_position()
	var avoidDistance = 200.0
	
	var nearestPlanet = global.planet_container.get_nearest_planet(myPos)
	if nearestPlanet != destinationPlanet and nearestPlanet != OriginPlanet: # you're allowed to land on the destination
		var planetPos = nearestPlanet.get_global_position()
		if myPos.distance_squared_to(planetPos) < avoidDistance * avoidDistance:
			returnVec += (myPos - planetPos).normalized()
	return returnVec
	
func get_peer_avoidance_vector():
	var returnVec = Vector2(0,0)
	var myPos = get_global_position()
	var avoidDistance = 35.0
	
	for ship in get_parent().get_children():
		var shipPos = ship.get_global_position()
		if ship != self:
			if myPos.distance_squared_to(shipPos) < avoidDistance * avoidDistance:
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

func _on_FiringArc_area_entered(area):
	if area.is_in_group("ships") and area.FactionObj != FactionObj:
		
		if $Weapons.WeaponStatus == $Weapons.Status.READY:
			$Weapons.CommenceFiring()
			disable_firingArc()
		# TODO: what happens if the weapons aren't ready? should it circle for another pass?
		

func _on_FiringArc_body_entered(body):
	if body.is_in_group("planets") and body.FactionObj != self.FactionObj:
		# the ship reached it's target planet. Break off from the path and start bombardment
		
		if $Weapons.WeaponStatus == $Weapons.Status.READY:
			$Weapons.CommenceFiring()
			
			disable_collision_shapes()
		# TODO: what happens if the weapons aren't ready? should it circle for another pass?
		
		
func _on_hit(damage, factionObj): # is factionObj the attacker or defender?
	Health -= damage
	if Health < 0:
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

