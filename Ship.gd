"""
Ships will:
	detect collisions with enemies
	try and avoid peers
	attack planets

"""

extends Area2D

var VelocityVectors:Array = []
var Speed : float = 150.0
var TurnSpeed : float = 2.5
var Faction : int
var IsHumanPlayer: bool = false
var MyFleet: Node2D
export var BulletScene : PackedScene
var Health = 1
var NavTarget # could be Position2D (FleetTarget) or StaticBody2D (planet)
var OriginPlanet : StaticBody2D
var TimeElapsed : float = 0
var Ticks: int = 0
onready var FiringArcCollisionShape = $FiringArc/CollisionPolygon2D

var VectorToGoal # for debug drawing

enum States { ADVANCING, RETURNING, BOMBARDING, DEAD }
var State = States.ADVANCING

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ships")

# Called by fleet
func start(faction, navTarget, originPlanet):
	Faction = faction
	if Faction == global.PlayerFaction:
		IsHumanPlayer = true
	set_color(Faction)
	OriginPlanet = originPlanet
	$Sprite.set_frame(faction)
	MyFleet = get_parent().get_parent() # each fleet has a ShipsContainer node
	NavTarget = navTarget

func set_color(faction):
	var factionColors = [ Color.gray, Color.steelblue, Color.firebrick ]
	$Sprite.set_self_modulate(factionColors[faction])
	$Weapons.set_modulate(factionColors[faction])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.DEAD:
		return
		
	TimeElapsed += delta
	Ticks += 1
	
	#set_position($"..".position)
#	if not Input.is_action_pressed("left_click"):
#		set_global_position($"../PathFollow2D".get_global_position())
	collectVelocityVectors()
	move(delta)
	$StatusLabel.text = NavTarget.name

	update() # refreshes _draw()
	
	if State == States.RETURNING:
		# hack to prevent hovering around planets you never left
		land_on_nearby_planet()
	
func land_on_nearby_planet():
	if NavTarget == null:
		die()
	else:
		var myPos = get_global_position()
		var targetPos = NavTarget.get_global_position()
		var landingDistance = 50.0
		if myPos.distance_squared_to(targetPos) < landingDistance * landingDistance:
			land(NavTarget)


	
func move(delta):
	var vectorToGoal = averageVelocityVectors()
	VectorToGoal = vectorToGoal
	
	var myPos = get_global_position()

	turnTowardsTarget(vectorToGoal, delta)

	var fwd = Vector2.RIGHT.rotated(rotation)
	set_global_position(myPos + fwd * delta * Speed * global.game_speed)
	
	#set_global_position(myPos + vectorToGoal * delta * Speed * global.game_speed)
	
	
	
func turnTowardsTarget(vectorToGoal, delta):
	var myRot = get_global_rotation()
	var myFwdVector = Vector2.RIGHT.rotated(myRot)
	var angleToGoal = myFwdVector.angle_to(vectorToGoal)
	
	self.rotate(angleToGoal * TurnSpeed * delta * global.game_speed)
	# note, this will rotate more and more slowly as it gets closer to the target rotation.
	
			  
func collectVelocityVectors():
	VelocityVectors = []
	VelocityVectors.push_back(get_peer_avoidance_vector())
	VelocityVectors.push_back(get_fleet_path_vector()*2.0)
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



func get_peer_avoidance_vector():
	var returnVec = Vector2(0,0)
	var myPos = get_global_position()
	var avoidDistance = 25.0
	
	for ship in get_parent().get_children():
		var shipPos = ship.get_global_position()
		if ship != self:
			if myPos.distance_squared_to(shipPos) < avoidDistance * avoidDistance:
				returnVec -= shipPos - myPos
	returnVec = returnVec.normalized()
	return returnVec

func die():
	call_deferred("disable_collision_shapes")
	State = States.DEAD
	
	var animPlayer = $death/AnimationPlayer
	animPlayer.play("explode")
	
	yield(animPlayer, "animation_finished")
	#yield(get_tree().create_timer(0.95), "timeout")
	call_deferred("queue_free")

func disable_collision_shapes(): # for death
	$CollisionShape2D.call_deferred("set_disabled", true)
	FiringArcCollisionShape.call_deferred("set_disabled", true)

func disable_firingArc():
	FiringArcCollisionShape.call_deferred("set_disabled", true)
	
func enable_firingArc():
	FiringArcCollisionShape.call_deferred("set_disabled", false)

func _on_FiringArc_area_entered(area):
	if area.is_in_group("ships") and area.Faction != Faction:
		
		if $Weapons.WeaponStatus == $Weapons.Status.READY:
			$Weapons.CommenceFiring()
			disable_firingArc()
		# TODO: what happens if the weapons aren't ready? should it circle for another pass?
		

func _on_FiringArc_body_entered(body):
	if body.is_in_group("planets") and body.Faction != Faction:
		# the ship reached it's target planet. Break off from the path and start bombardment
		
		if $Weapons.WeaponStatus == $Weapons.Status.READY:
			$Weapons.CommenceFiring()
			
			disable_collision_shapes()
		# TODO: what happens if the weapons aren't ready? should it circle for another pass?
		
		
func _on_hit(damage, faction):
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
	if planet.Faction == Faction:
		State = States.DEAD
		planet.add_units(1)
		call_deferred("disable_collision_shapes")
		call_deferred("queue_free")
	else:
		print("Something's wrong, ship is trying to land on an enemy planet")


func _on_Ship_body_entered(body):
	if body.is_in_group("planets"):
		var planet = body
		if TimeElapsed > 1.0: # otherwise fires too quickly. need to check if it's our planet of origin
			if planet.Faction == Faction:
				land(planet)
			else:
				# you landed on the enemy planet. remove 1 from their population tit for tat
				planet._on_hit(1, Faction, self.get_global_position())
				die()
				# might want to add a small animation? maybe too small to notice though
				
				


func _on_SwapMagazineTimer_timeout(): #Weapons say they're ready again
	enable_firingArc()
	
	
