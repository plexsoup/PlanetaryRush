extends Area2D

var Velocity : Vector2
var Faction : int
var Damage : float = 0.5
signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(pos, rot, vel, faction):
	Faction = faction
	set_color(faction)
	set_global_rotation(rot)
	set_global_position(pos)
	Velocity = vel
	$pewpew.set_pitch_scale(rand_range(0.9, 1.1))
	$pewpew.play()

func set_color(faction):
	set_modulate(global.FactionColors[Faction])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_global_position(get_global_position() + Velocity * delta * global.game_speed)


func die():
	call_deferred("queue_free")


func _on_laser_area_entered(area):
	# hit a ship, kill it
	if area.is_in_group("ships") and area.Faction != Faction:
		if area.has_method("_on_hit"):
			if not is_connected("hit", area, "_on_hit"):
				connect("hit", area, "_on_hit")
			emit_signal("hit", Damage, Faction)
			die()
			


func _on_laser_body_entered(body):
	# hit a planet. kill some population
	if body.is_in_group("planets") and body.Faction != Faction:
		var enemyPlanet = body
		if enemyPlanet.has_method("_on_hit"):
			if not is_connected("hit", enemyPlanet, "_on_hit"):
				connect("hit", enemyPlanet, "_on_hit")
			emit_signal("hit", Damage, Faction)
			die()



func _on_Timer_timeout():
	die()
