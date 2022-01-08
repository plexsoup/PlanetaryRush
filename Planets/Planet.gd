extends StaticBody2D

# Declare member variables here. Examples:
var units_present : float = -1.0
var original_scale: Vector2
var scale_factor: float = 70.0
var base_production: float = 1.0 # based on planet size
var production_factor: float = 1.02
var max_population : int = 40
var difficulty_factor : float # 1, 2, 3.5
enum States { INITIALIZING, READY }
var State:int = States.INITIALIZING

# Game-Feel, Juice, Bounce and Pop
var juicy_bounce_factor: float = 1.25
var trans_mode = Tween.TRANS_ELASTIC
var ease_mode = Tween.EASE_IN_OUT

var focused : bool = false
var FactionObj : Node2D

signal switched_faction(planetObj, newFactionObj)
signal assigned_fleet(fleetObj)
signal no_ships_available()

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_collision_shape()
	set_random_properties()
	update_unit_label()
	add_to_group("planets")
	State = States.READY
	
func start(factionObj, size):
	var myName = generateName()
	self.name = myName
	switch_faction(factionObj)
	set_planet_size(size)
	set_difficulty(factionObj)

	
	if global.Debug:
		$PlanetNameLabel.text = myName
		$PlanetNameLabel.set_visible(true)

	else:
		$PlanetNameLabel.set_visible(false)
	
func generateName():
	var newName = ""
	var markovElements = [
		"em", "by", "wo", "pe", "oe", "ly", "thi", "for", "shu", "la", "tae", "mar"
	]
	markovElements.shuffle()
	for i in range(randi()%4+1):
		newName += markovElements.pop_back()
	newName = newName.capitalize()
	return newName

func set_difficulty(factionObj):
	if factionObj.IsLocalHumanPlayer:
		difficulty_factor = 1.0
	else:
		difficulty_factor = 1.0+(float(global.options["difficulty"] ) * 0.75)
	
func initialize_collision_shape():
	var shape = CollisionShape2D.new()
	shape.set_shape(CircleShape2D.new())
	shape.get_shape().set_radius(70.0)
	shape.set_name("CollisionShape2D")
	add_child(shape)
	
	
# **** Not sure what to do here.
func set_random_properties():
	set_random_texture()
	#var colors = global.FactionColors
	#set_faction(global.NeutralFactionObj) # most will start grey
	#printerr("Planet.set_random_properties requires refactor")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_random_size():
	set_planet_size(rand_range(0.5, 2.5))

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

func set_faction(factionObj):
	if not is_instance_valid(factionObj):
		# dude, your ships claimed a new planet, but your faction already quit!
		# that's cold.
		printerr("A faction managed to claim a planet AFTER it resigned. They should have been allowed to continue.")
		return
		
	# note, does not notify the factions about the change!
	# Use Switch faction instead.
	FactionObj = factionObj
	var myColor = factionObj.fColor
	if global.Debug: 
		myColor.a = 0.5
	$Sprite.set_self_modulate(myColor)
	
func switch_faction(newFaction):
	if not is_instance_valid(newFaction):
		# ships tried to claim a planet after your faction disappeared
		return
		
	var oldFaction = FactionObj
	if oldFaction == newFaction:
		printerr("Planet is trying to switch factions from itself to itself.")
		return
	else:
		set_faction(newFaction)
		# notify factions about the change in planets
		for faction in [newFaction, oldFaction]:
			if is_instance_valid(faction):
				connect("switched_faction", faction, "_on_planet_switched_faction")
				emit_signal("switched_faction", self, newFaction)
				disconnect("switched_faction", faction, "_on_planet_switched_faction")
			else:
				# Probably setting up a new planet.
				# Or possibly trying to notify a faction that was queued_free already.
				pass


func increase_units_from_timed_production():
	
	var baseProd = base_production * difficulty_factor * global.game_speed
	var popGrowth = ((units_present * production_factor) - units_present) * global.game_speed
	units_present = clamp( units_present + baseProd + popGrowth, 1, max_population)
	update_unit_label()


func add_units(number):
	units_present += number
	update_unit_label()

func remove_units(number):
	units_present -= number
	update_unit_label()

func _on_ProductionTimer_timeout():
	if not FactionObj.IsNeutralFaction: # grey planets don't produce
		increase_units_from_timed_production()




func take_focus(): # called by Cursor
	if self.FactionObj.IsLocalHumanPlayer:
		popUp(original_scale, original_scale * juicy_bounce_factor)
		focused = true

func lose_focus(): # called by Cursor
	if self.FactionObj.IsLocalHumanPlayer:
		popUp(original_scale * juicy_bounce_factor, original_scale)
		focused = false

func popUp(initial_scale, final_scale):
	if State == States.INITIALIZING:
		return #wait until ready
	
	# hmmm, this is throwing errors sometimes. $Tween doesn't get added to the scene fast enough?
	
	var tween = $Tween
	var sprite = $Sprite
	tween.interpolate_property(sprite, "scale", initial_scale, final_scale , 0.3, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0)
	tween.call_deferred("start")
	if initial_scale.x < final_scale.x:
		$AudioStreamPlayer2D.play()

func send_ships(number, path, destinationPlanet):
	spawn_fleet(number, path, destinationPlanet)
	units_present -= number

func spawn_fleet(numShips, path, destinationPlanet): # coming from Planet
	var originPlanet = self
	var shipScene = load("res://Ships/Ship.tscn")
	var fleetScene = load("res://Ships/Fleet.tscn")

	var fleet = fleetScene.instance()
	global.level.FleetContainer.add_child(fleet)
	fleet.set_global_position(get_global_position())
	fleet.start(path, FactionObj, numShips, shipScene, originPlanet, destinationPlanet)

	connect( "assigned_fleet", path, "_on_planet_assigned_fleet")
	emit_signal("assigned_fleet", fleet)
	disconnect( "assigned_fleet", path, "_on_planet_assigned_fleet")
	


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
	newFirework.start(pos, rot, vel, FactionObj)
	
func spawn_explosion():
	pass
	


##################################################################################
# Outgoing Signals

func notifyPath_PlanetCannotSendShips(path):
	connect("no_ships_available", path, "_on_planet_cannot_send_ships")
	emit_signal("no_ships_available")
	disconnect("no_ships_available", path, "_on_planet_cannot_send_ships")


##################################################################################
# Incoming Signals


# signal coming from cursor via global.level
func _on_ShipPath_finished_drawing(path, destinationPlanet):
	# send half your ships along the path
	if path.FactionObj == FactionObj and units_present >= 2:
		send_ships(units_present/2, path, destinationPlanet)
	else:
		# respond with a denial so the path can kill itself.
		notifyPath_PlanetCannotSendShips(path)
	
func _on_hit(damage, factionObj, location = get_global_position()):
	# maybe ships lasers are too powerful
	if factionObj != FactionObj:
		remove_units(damage)
		if units_present <= 0:
			switch_faction(factionObj)
			
		units_present = 0
		
	if global.Debug:
		update_unit_label()

func _on_ship_landed(damage, factionObj):
	# switch to the new faction if you're neutral
	
	if FactionObj == global.NeutralFactionObj:
		if units_present <= 0: # empty neutral, claim it
			switch_faction(factionObj)
			#add_units(damage)
			
		else: # populated neutral, reduce population
			remove_units(damage)
			if units_present <= 0:
				switch_faction(factionObj)
	elif FactionObj == factionObj: # friendly planet, add population
		add_units(damage)
	else: # enemy planet, reduce population
		remove_units(damage)
		if units_present <= 0:
			switch_faction(global.NeutralFactionObj)
			#units_present = 1

func _on_initialize_faction(factionObj):
	switch_faction(factionObj)
