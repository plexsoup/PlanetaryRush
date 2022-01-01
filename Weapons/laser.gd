extends Area2D

var Velocity : Vector2
var FactionObj : Node2D
var Damage : float = 0.5
var DefaultLifespan : float = 0.25
signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(pos, rot, vel, factionObj):
	FactionObj = factionObj
	set_color(factionObj)
	set_global_rotation(rot)
	set_global_position(pos)
	Velocity = vel
	$pewpew.set_pitch_scale(rand_range(0.9, 1.1))
	$pewpew.play()

	if global.game_speed > 0:
		$Timer.start(DefaultLifespan / global.game_speed)
	

func set_color(factionObj):
	set_modulate(factionObj.fColor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_global_position(get_global_position() + Velocity * delta * global.game_speed)


func die():
	call_deferred("queue_free")


func _on_laser_area_entered(area):
	# hit a ship, kill it
	if area.is_in_group("ships") and area.FactionObj != FactionObj:
		if area.has_method("_on_hit"):
			if not is_connected("hit", area, "_on_hit"):
				connect("hit", area, "_on_hit")
			emit_signal("hit", Damage, FactionObj)
			die()
			


func _on_laser_body_entered(body):
	# hit a planet. kill some population
	if body.is_in_group("planets") and body.FactionObj != FactionObj:
		var enemyPlanet = body
		if enemyPlanet.has_method("_on_hit"):
			if not is_connected("hit", enemyPlanet, "_on_hit"):
				connect("hit", enemyPlanet, "_on_hit")
			emit_signal("hit", Damage, FactionObj)
			die()



func _on_Timer_timeout():
	die()
