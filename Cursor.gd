extends Area2D

enum States { PAUSED, ACTIVE, LOCKED }
var State = States.ACTIVE

var cursor_range : float = 3000
var lerp_toward_mouse_speed : float = 0.8

var current_planet : StaticBody2D
var Faction : int

signal new_path_requested(planet)

func _ready():
	global.cursor = self
	if global.PlayerFaction:
		Faction = global.PlayerFaction
	global.camera = $Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.ACTIVE and is_inside_margins():
		set_global_position(lerp(get_global_position(), get_global_mouse_position(), lerp_toward_mouse_speed))

func _input(event):
	if Input.is_action_just_pressed("left_click"):
		current_planet = get_closest_planet()
		#print(self.name, " my Faction == ", Faction)
		#print(self.name, " planet Faction == ", current_planet.Faction)
		if Faction == current_planet.Faction:
			lock_cursor_on(current_planet)
			spawnPath(current_planet)

func set_faction(factionNum):
	Faction = factionNum
	#print("setting faction to ", Faction)

func lock_cursor_on(planet):
	set_global_position(planet.get_global_position())
	State = States.LOCKED
		
func spawnPath(planet):
	connect("new_path_requested", global.level, "_on_new_path_requested")
	emit_signal("new_path_requested", planet)
	disconnect("new_path_requested", global.level, "_on_new_path_requested")
	

func get_closest_friendly_planet():
	return global.planet_container.get_nearest_faction_planet(get_global_position(), Faction)


func get_closest_planet():
	return global.planet_container.get_nearest_planet(get_global_position())
	
#	var myPos = get_global_position()
#	var closest = null
#	var closest_dist_sq = 10000000
#	for planet in global.planet_container.get_children():
#		var planetPos = planet.get_global_position()
#		var dist_sq_to_planet = myPos.distance_squared_to(planetPos)
#		if dist_sq_to_planet < closest_dist_sq:
#			closest_dist_sq = dist_sq_to_planet
#			closest = planet
#	return closest

func is_inside_margins():
	if get_global_mouse_position().length_squared() >= cursor_range * cursor_range:
		return false
	else:
		return true

func _on_Cursor_body_entered(body):
	if body.is_in_group("planets"):
		if body.has_method("take_focus"):
			body.take_focus()

func _on_Cursor_body_exited(body):
	if body.is_in_group("planets"):
		if body.has_method("lose_focus"):
			body.lose_focus()

func _on_pause_menu_opened():
	State = States.PAUSED
	
func _on_pause_menu_closed():
	State = States.ACTIVE
	
func _on_ShipPath_finished_drawing(path):
	State = States.ACTIVE
