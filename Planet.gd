extends StaticBody2D

# Declare member variables here. Examples:
var units_present : float = -1.0
var original_scale: Vector2
var scale_factor: float = 70.0
var base_production: float = 1.0
var production_factor: float = 1.02
var max_population : int = 40
var difficulty_factor : float # 1, 2, 3.5

# Game-Feel, Juice, Bounce and Pop
var juicy_bounce_factor: float = 1.25
var trans_mode = Tween.TRANS_ELASTIC
var ease_mode = Tween.EASE_IN_OUT

var focused : bool = false
var Faction : int


# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_collision_shape()
	set_random_properties()
	update_unit_label()
	add_to_group("planets")
	
func start(faction, size):
	set_faction(faction)
	set_planet_size(size)
	set_difficulty(faction)

func set_difficulty(faction):
	if faction != global.PlayerFaction:
		difficulty_factor = 1.0+(float(global.options["difficulty"])/2.0)
		#print("difficulty_factor = " , difficulty_factor)
	else:
		difficulty_factor = 1.0
	
func initialize_collision_shape():
	var shape = CollisionShape2D.new()
	shape.set_shape(CircleShape2D.new())
	shape.get_shape().set_radius(70)
	shape.set_name("CollisionShape2D")
	add_child(shape)
	
func set_random_properties():
	set_random_texture()
	var colors = global.FactionColors
	set_faction(0) # most will start grey

	#set_random_size() # moved logic to Planets.gd

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_random_size():
	set_planet_size(rand_range(0.3, 1.5))

func set_planet_size(size):
	var newScale = Vector2(1,1) * size
	$Sprite.set_scale(newScale)
	original_scale = newScale

	$CollisionShape2D.get_shape().set_radius(size * scale_factor)
	units_present = int(size * 10)
	base_production = size / 5.0
	
func update_unit_label():
	$Production/ProductionLabel.set_text(str(floor(units_present)))
	if global.camera != null:
		$Production.set_scale(lerp($Production.get_scale(), global.camera.get_zoom() / 5.0, 0.8))
	
func set_random_texture():
	$Sprite.set_frame(randi()%9)

func set_faction(faction):
	var colors = global.FactionColors
	Faction = faction
	$Sprite.set_self_modulate(colors[Faction])

func increase_units():
	units_present = clamp( (base_production * difficulty_factor) + (units_present * production_factor), 1, max_population)
		

func _on_ProductionTimer_timeout():
	if Faction != 0: # grey planets don't produce
		increase_units()
	update_unit_label()



func take_focus(): # called by Cursor
	popUp(original_scale, original_scale * juicy_bounce_factor)
	focused = true

func lose_focus(): # called by Cursor
	popUp(original_scale * juicy_bounce_factor, original_scale)
	focused = false

func popUp(initial_scale, final_scale):
	var tween = $Tween
	var sprite = $Sprite
	tween.interpolate_property(sprite, "scale", initial_scale, final_scale , 0.3, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0)
	tween.start()
	if initial_scale.x < final_scale.x:
		$AudioStreamPlayer2D.play()

func send_ships(number, path):
	spawn_fleet(number, path)
	units_present -= number

func send_ai_ships(number, destinationPlanet):
	spawn_ai_fleet(number, destinationPlanet)
	units_present -= number

func spawn_fleet(numShips, path): # coming from Planet
	var originPlanet = self
	var shipScene = load("res://Ship.tscn")
	var fleetScene = load("res://Fleet.tscn")

	var fleet = fleetScene.instance()
	global.level.FleetContainer.add_child(fleet)
	fleet.set_global_position(get_global_position())
	fleet.start(path.get_node("PathFollow2D"), Faction, numShips, shipScene, originPlanet)

func spawn_ai_fleet(numShips, destinationPlanet):
	var originPlanet = self
	var shipScene = load("res://Ship.tscn")
	var fleetScene = load("res://Fleet.tscn")

	var fleet = fleetScene.instance()
	global.level.FleetContainer.add_child(fleet)
	fleet.set_global_position(get_global_position())
	fleet.start_AI_fleet(Faction, numShips, shipScene, originPlanet, destinationPlanet)
	
func celebrate():
	for i in range(randi()%15+5):
		spawn_firework()
		yield(get_tree().create_timer(rand_range(0.01, 0.1)), "timeout")
		
func spawn_firework():
	var rot = randf()*2.0*PI
	var fireworkScene = load("res://effects/Firework.tscn")
	var newFirework = fireworkScene.instance()
	$Fireworks.add_child(newFirework)
	var speed = 200.0
	var deviation = 50.0
	var vel = Vector2.RIGHT.rotated(rot) * rand_range(speed-deviation, speed+deviation)
	var pos = get_global_position()
	newFirework.start(pos, rot, vel, Faction)
	


func add_units(number):
	units_present += number

func _on_ShipPath_finished_drawing(path):
	# send half your ships along the path
	send_ships(units_present/2, path)

func _on_AI_requested_ships(destinationPlanet):
	send_ai_ships(units_present/2, destinationPlanet)
	
func _on_hit(damage, faction):
	units_present -= damage
	if units_present <= 0:
		# switch sides
		set_faction(faction)
	update_unit_label()
