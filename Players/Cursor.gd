extends Area2D

enum States { PAUSED, ACTIVE, LOCKED, DRAWING, SEEKING }
var State = States.ACTIVE

var cursor_range : float = 3000


var current_planet : StaticBody2D
var FactionObj : Node2D

export (PackedScene) var PlayerControllerScene = null
export (PackedScene) var AIControllerScene = null
var ControllerObj : Node2D # could be local_human or AI or (future) network player

signal new_path_requested(planet)

func _ready():
	pass

func start(factionObj, isLocalHumanPlayer):
	check_requirements()
	
	set_faction(factionObj)
	setupCamera(factionObj)
	if isLocalHumanPlayer:
		global.cursor = self # who uses this? Camera?
	spawn_player_controller(factionObj, isLocalHumanPlayer)


func check_requirements():
	if PlayerControllerScene == null:
		printerr("Error in " + self.name + ": PlayerController needs a scene in the inspector")
		
	if AIControllerScene == null:
		printerr("Error in " + self.name + ": AIController needs a scene in the inspector")

func setupCamera(factionObj):
	if factionObj.IsLocalHumanPlayer:
		global.camera = $Camera2D
		$Camera2D.current = true

	else: # AI don't really need a camera
		$Camera2D.call_deferred("queue_free")
	# Someday we may have to tweak the camera settings if we add multiplayer / network

func spawn_player_controller(factionObj, isLocalHumanPlayer):
	#Set up an event listener for the player, or a bot for AI
	if isLocalHumanPlayer:
		var newPlayerController = PlayerControllerScene.instance()
		self.add_child(newPlayerController)
		ControllerObj = newPlayerController
	else:
		var newAIController = AIControllerScene.instance()
		self.add_child(newAIController)
		newAIController.start(factionObj)
		ControllerObj = newAIController

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.Debug:
		$DebugInfoLabel.text = str(get_global_position())
#		if global.Ticks % 200 == 0:
#			print("Cursor, current state is : " + States.keys()[State])

func set_faction(factionObj):
	FactionObj = factionObj
	$Sprite.set_self_modulate(factionObj.fColor)


func lock_cursor_on(planet):
	set_global_position(planet.get_global_position())
	State = States.LOCKED
		
func spawnPath(planet):
	if planet.FactionObj == self.FactionObj:
		connect("new_path_requested", global.level, "_on_new_path_requested")
		emit_signal("new_path_requested", planet, FactionObj, self)
		disconnect("new_path_requested", global.level, "_on_new_path_requested")
	else:
		printerr("Cursor.gd: someone's trying to draw paths from unowned planets")

func get_closest_friendly_planet():
	return global.planet_container.get_nearest_faction_planet(get_global_position(), FactionObj)

func get_closest_planet():
	return global.planet_container.get_nearest_planet(get_global_position())

func is_inside_margins():
	if get_global_mouse_position().length_squared() >= cursor_range * cursor_range:
		return false
	else:
		return true

func isStillDrawing():
	# expose this to ShipPaths so they know when to terminate drawing and spawn ships
	# ask the current player controller for a response, then furnish the respons to the shipPath
	if is_instance_valid(ControllerObj):
		return ControllerObj.isStillDrawing()
	else:
		printerr("Cursor.gd is looking for a nonexistent Player Controller. Maybe the faction was queue_free'd")
		return false

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

func _on_PlayerController_Clicked(): # signal emulates a mouse click, but it could come from AI
	if global.State == global.States.FIGHTING:
		current_planet = get_closest_planet()
		if current_planet:
			#lock_cursor_on(current_planet)
			spawnPath(current_planet)

func _on_PlayerController_Released(): # signal a mouse left-button release.
	State = States.ACTIVE #**** Is this even close to correct?
	
	
	

