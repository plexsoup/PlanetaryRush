"""
Ships will:
	detect collisions with enemies
	try and avoid peers
	attack planets

"""

extends Area2D

var VelocityVectors:Array = []
var Speed : float = 150.0
var TurnSpeed : float = 5.0
var Faction : int
export var BulletScene : PackedScene
var Health = 1
var NavTarget # could be Position2D (FleetTarget) or StaticBody2D (planet)
var OriginPlanet : StaticBody2D
var TimeElapsed : float = 0

var VectorToGoal # for debug drawing

enum States { ADVANCING, RETURNING }
var State = States.ADVANCING

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ships")

# Called by fleet
func start(faction, navTarget, originPlanet):
	Faction = faction
	set_color(Faction)
	OriginPlanet = originPlanet
	$Sprite.set_frame(faction)
	NavTarget = navTarget

func set_color(faction):
	var factionColors = [ Color.gray, Color.steelblue, Color.firebrick ]
	set_modulate(factionColors[faction])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	TimeElapsed += delta
	#set_position($"..".position)
#	if not Input.is_action_pressed("left_click"):
#		set_global_position($"../PathFollow2D".get_global_position())
	collectVelocityVectors()
	move(delta)
	update()
	
	if State == States.RETURNING:
		# hack to prevent hovering around planets you never left
		land_on_nearby_planet()
	
func land_on_nearby_planet():
	var myPos = get_global_position()
	var targetPos = NavTarget.get_global_position()
	var landingDistance = 70.0
	if myPos.distance_squared_to(targetPos) < landingDistance * landingDistance:
		if NavTarget.has_method("add_units"):
			NavTarget.add_units(1)
		die()
	if NavTarget == null:
		die()

	
func move(delta):
	var vectorToGoal = averageVelocityVectors()
	VectorToGoal = vectorToGoal
	
	var myPos = get_global_position()
	#set_global_position(myPos + Vector2.RIGHT.rotated(rotation) * delta * Speed)
	set_global_position(myPos + vectorToGoal * delta * Speed * global.game_speed)
	turnTowardsTarget(vectorToGoal, delta)
	
	
	
func turnTowardsTarget(vectorToGoal, delta):
	var myRot = get_global_rotation()
	var rotToGoal = Vector2.RIGHT.angle_to(vectorToGoal)
	set_global_rotation(lerp(myRot, rotToGoal, TurnSpeed * delta * global.game_speed))
	

func collectVelocityVectors():
	VelocityVectors = []
	VelocityVectors.push_back(get_peer_avoidance_vector())
	VelocityVectors.push_back(get_fleet_path_vector())
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
	call_deferred("queue_free")

func disable_collision_shapes():
	$CollisionShape2D.set_disabled(true)
	$"Front/CollisionShape2D".set_disabled(true)
	$"FiringArc/CollisionPolygon2D".set_disabled(true)

func _on_FiringArc_area_entered(area):
	if area.is_in_group("ships") and area.Faction != Faction:
		$Weapons.CommenceFiring()
		

func _on_FiringArc_body_entered(body):
	if body.is_in_group("planets") and body.Faction != Faction:
		$Weapons.CommenceFiring()
		
func _on_hit(damage, faction):
	Health -= damage
	if Health < 0:
		die()
		
func _draw():
	if global.Debug:
		var myPos = get_global_position()
		draw_line(to_local(myPos), to_local(VectorToGoal*20 + myPos), Color.azure, 3, true)
	

func _on_Ship_body_entered(body):
	if body.is_in_group("planets"):
		if TimeElapsed > 1.0: # otherwise fires too quickly. need to check if it's our planet of origin
			if body.Faction == Faction:
				body.add_units(1)
				die()
			else:
				body._on_hit(1, Faction)
				die()
				
