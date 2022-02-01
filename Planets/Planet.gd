extends StaticBody2D

# refactoring opportunity: optimization.
# it may be costly to connect and discconnect signals all the time
# instead, you could keep the referee connected all the time,
# connect a newFaction before the signal
# disconnect the oldFaction after the signal
# then send only one signal (to three recipients oldFaction, newFaction, referee)


# Note. The inspector complains about a missing collision shape, but we build them dynamically because each planet has a different size
	# godot likes to share a collision shape across instanced clones. So you can't easily adjust the size on the fly. Better to generate new shape for each object.

# Declare member variables here. Examples:
var Level : Node2D
export var FactionNum : int

export var Size : float = 1.0
var units_present : float = 1.0 # billions of people
var original_scale: Vector2
var scale_factor: float = 70.0
var base_production: float = 1.0 # based on planet size
#var production_factor: float = 1.02
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

var OutboundPath : Path2D = null
#var InboundPaths : Array = []

signal switched_faction(planetObj, newFactionObj)
#signal assigned_fleet(fleetObj)
signal no_ships_available()
signal path_replaced()

# Called when the node enters the scene tree for the first time.
func _ready():

	initialize_collision_shape()
	set_random_properties()
	update_unit_label()
	add_to_group("planets")
	State = States.READY
	
func start(levelObj = null, size : float = 1.0):
	if levelObj == null:
		print("wtf Planet.gd?")
	Level = levelObj
	Size = size
	var myName = generateName()
	self.name = myName
	
	$Sprite.set_self_modulate(Color.darkcyan)
	$FocusRing.hide()

	set_planet_size(size)
	set_initial_population(size)
	update_unit_label()

#	if FactionNum != 0:
#		switch_faction(FactionNum) # means level has to spawn factions before planets

	
	if global.Debug:
		$PlanetNameLabel.text = myName
		$PlanetNameLabel.set_visible(true)

	else:
		$PlanetNameLabel.set_visible(false)

func end():
	call_deferred("queue_free") # shouldn't need to notify anyone
	
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.Ticks % 50 == 0:
		update_unit_label()

func set_random_size():
	set_planet_size(rand_range(0.5, 2.5))

func set_planet_size(size):
	var newScale = Vector2(1,1) * size
	$Sprite.set_scale(newScale)
	original_scale = newScale

	$CollisionShape2D.get_shape().set_radius(size * scale_factor)
	base_production = size / 5.0 # units_present and size have to be floats
	
func set_initial_population(size):
	units_present = size * 5.0


func update_unit_label():
	$Production/ProductionLabel.set_text(str(floor(units_present)))
	$Production.set_scale(lerp($Production.get_scale(), get_font_scale(), 0.8))

func get_font_scale():
	var fontScale : Vector2 = Vector2(1.0, 1.0)

	var screen = get_viewport()
	var zoom = screen.get_canvas_transform().get_scale()
	fontScale = fontScale * ( 0.25 / zoom.x )
	
	return fontScale

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
	$FocusRing.set_modulate(myColor)
	
func switch_faction(level, newFaction):
	var interestedEntities : Array = []
	if not is_instance_valid(newFaction):
		if typeof(newFaction) == TYPE_INT:
			newFaction = Level.LookupFaction(newFaction)
		
	var oldFaction = FactionObj # may be null for neutral planets
	if oldFaction != newFaction:
		set_faction(newFaction)
		units_present = 1.0
		update_unit_label()
		# notify factions about the change in planets
		
		interestedEntities.push_back(newFaction)
		interestedEntities.push_back(oldFaction)
		interestedEntities.push_back(level.get_referee()) # This is causing errors
		
		var activePaths : Array = []
		
		if is_instance_valid(Level):
			activePaths = Level.get_paths_to(self)
			interestedEntities.append_array(activePaths)
		
		notifyEntities_planet_switched_faction(interestedEntities, oldFaction, newFaction)
		
#		for faction in [newFaction, oldFaction]:
#			if is_instance_valid(faction):
#				notify_faction_planet_switched(faction, newFaction)
#		notify_referee_planet_switched(newFaction, oldFaction)



func increase_units_from_timed_production():
	# game_feel opportunity: difficulty factor should only affect AI planets
	var baseProd = base_production * difficulty_factor * global.game_speed
#	var popGrowth = ((units_present * production_factor) - units_present) * global.game_speed
	var popGrowth = base_production * (1 + Size/2) # size spread seems too high so we fudge it a bit here.
	units_present = clamp( units_present + popGrowth, 1, max_population)
	update_unit_label()


func add_units(number):
	units_present += number
	update_unit_label()

func remove_units(number):
	units_present -= number
	update_unit_label()






func take_focus(): # called by Cursor
	if is_instance_valid(FactionObj):
		if self.FactionObj.IsLocalHumanPlayer:
			popUp(original_scale, original_scale * juicy_bounce_factor)
			focused = true
			$FocusRing.show()

func lose_focus(): # called by Cursor
	if is_instance_valid(FactionObj):
		if self.FactionObj.IsLocalHumanPlayer:
			popUp(original_scale * juicy_bounce_factor, original_scale)
			focused = false
			$FocusRing.hide()

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
	Level.FleetContainer.add_child(fleet)
	fleet.set_global_position(get_global_position())
	fleet.start(path, FactionObj, numShips, shipScene, originPlanet, destinationPlanet, Level)



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
# Global functions: may be called by other scripts

func get_population():
	return units_present

##################################################################################
# Outgoing Signals

func notifyEntities_planet_switched_faction(interestedEntities : Array, oldFaction, newFaction):
	# inbound and outbound paths, referee, new and old factions
	for entity in interestedEntities:
		if is_instance_valid(entity):
			connect("switched_faction", entity, "_on_planet_switched_faction")
	emit_signal("switched_faction", self, newFaction)
	for entity in interestedEntities:
		if is_instance_valid(entity):
			disconnect("switched_faction", entity, "_on_planet_switched_faction")
	

func notify_path_PlanetCannotSendShips(path):
	connect("no_ships_available", path, "_on_planet_cannot_send_ships")
	emit_signal("no_ships_available")
	disconnect("no_ships_available", path, "_on_planet_cannot_send_ships")


func notify_path_replaced(path):
	printerr("bug: if the destination planet changes hands, no one notifies the path")
	
	# used to tell an old path it's no longer needed, since the planet has a new path.
	# each planet only gets one OutboundPath.
	if is_instance_valid(path):
		connect("path_replaced", path, "_on_planet_replaced_path")
		emit_signal("path_replaced")
		disconnect("path_replaced", path, "_on_planet_replaced_path")

##################################################################################
# Incoming Signals

func _on_ProductionTimer_timeout():
	if is_instance_valid(FactionObj):
		increase_units_from_timed_production()

# signal coming from cursor via Level
func _on_ShipPath_finished_drawing(newPath, originPlanet, destinationPlanet):
	if originPlanet == self:
		# send half your ships along the path
		if OutboundPath != null: # new path replaces old path.
			notify_path_replaced(OutboundPath)
		
		if newPath.FactionObj == FactionObj and units_present >= 2:
			send_ships(units_present/2, newPath, destinationPlanet)
			OutboundPath = newPath
		else:
			# respond with a denial so the path can kill itself.
			notify_path_PlanetCannotSendShips(newPath)
			
#	elif destinationPlanet == self:
#		InboundPaths.push_back(newPath) # this might be dumb.
		# do we really need to keep a list of inbound paths? It'll get out of date as paths kill themselves
	
func _on_ShipPath_requested_more_ships(path, destinationPlanet):
	if path.FactionObj == FactionObj and units_present >= 2:
		send_ships(units_present/2.0, path, destinationPlanet)
	else:
		# respond with a denial so the path can kill itself.
		notify_path_PlanetCannotSendShips(path)
		

func _on_hit(damage, factionObj, location = get_global_position()):
	# maybe ships lasers are too powerful
	if factionObj != FactionObj:
		remove_units(damage)
		if units_present <= 0:
			switch_faction(Level, factionObj)
			
		units_present = 0
		
	if global.Debug:
		update_unit_label()

func _on_ship_landed(damage, factionObj):
	
	if self.FactionObj == null:
		if units_present < 1.0: # empty neutral, claim it. #under 1.0 will look like zero in-game
			switch_faction(Level, factionObj)
		else: # populated neutral, reduce population
			remove_units(damage)
			if units_present < 1.0:
				switch_faction(Level, factionObj)
				
				
	elif FactionObj == factionObj: # friendly planet, add population
		add_units(damage)
	else: # enemy planet, reduce population
		remove_units(damage)
		if units_present <= 0:
			switch_faction(Level, factionObj)


func _on_initialize_faction(factionObj):
	switch_faction(Level, factionObj)
	set_initial_population(Size)
