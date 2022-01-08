extends Path2D

var last_point : Vector2
var min_point_separation : float = 15.0
var MyPlanet : StaticBody2D

enum States { DRAWING, FINISHED }
var State = States.DRAWING
var FactionObj : Node2D
var CursorObj : Node2D
var AssignedFleet : Node2D # will this ever be an array instead of a single object?


signal finished_drawing(path)
signal encountered_enemy(fleetObj)


func _ready():
	State = States.DRAWING
	last_point = Vector2.ZERO
	initialize_path()


func start(planet, factionObj, cursorObj):
	MyPlanet = planet
	CursorObj = cursorObj
	FactionObj = factionObj
	warp_to_planet(planet) # why?

func warp_to_planet(planet): 
	# relocate the cursor to the nearest planet, 
	# so the player can be sloppy with their inputs.
	if FactionObj.IsLocalHumanPlayer:
		Input.warp_mouse_position(planet.get_global_transform_with_canvas().get_origin())


func die():
	$DestructionTimer.set_wait_time(0.1)
	$DestructionTimer.start()

func _on_DestructionTimer_timeout():
	self.set_curve(Curve2D.new())
	update() # trigger the draw function to clear the previous path
	call_deferred("queue_free")

func _process(delta):
	update() # triggers _draw function
	


func initialize_path():
	var newCurve = Curve2D.new()
	set_curve(newCurve)
	


func add_point():
	var cursorPos : Vector2
	cursorPos = to_local(CursorObj.get_global_position())
	
#	if Faction == global.PlayerFaction:
#		cursorPos = get_local_mouse_position()

	var distSq = last_point.distance_squared_to(cursorPos)
	var minAllowableDistance = min_point_separation * min_point_separation
	if distSq > minAllowableDistance:
		self.get_curve().add_point(cursorPos)
		#print(str(Faction) + " adding point at " + str(cursorPos))
		last_point = cursorPos
	$MousePolling.start()
		
func find_faction_cursor():
	return null

###############################################################################
# Outbound Signals


func finish_path(destinationPlanet):
	
	$MousePolling.stop()
	State = States.FINISHED
	
	connect("finished_drawing", MyPlanet, "_on_ShipPath_finished_drawing")
	connect("finished_drawing", CursorObj, "_on_ShipPath_finished_drawing")
	
	emit_signal("finished_drawing", self, destinationPlanet)

	disconnect("finished_drawing", MyPlanet, "_on_ShipPath_finished_drawing")
	disconnect("finished_drawing", CursorObj, "_on_ShipPath_finished_drawing")

###############################################################################
# Incoming Signals


func _on_MousePolling_timeout():
	if CursorObj.isStillDrawing():
		add_point()
	else:
		var level = global.Main.CurrentLevel
		var nearestDestinationPlanet = level.PlanetContainer.get_nearest_planet(CursorObj.get_global_position())
		finish_path(nearestDestinationPlanet)
		
		
func _draw():
	if not is_instance_valid(FactionObj):
		return

	var pathFollowNode = get_node("PathFollow2D")
	var myCurve = self.get_curve()
	var lineLength = myCurve.get_baked_length()
	var points = myCurve.get_baked_points()
	var numPoints = points.size()
	var i : int = 0
	var factionColor = FactionObj.fColor

	for point in points:
		var pointColor = factionColor
		#Note: points have already been converted to_local for the draw function to work.
		var pointRatio: float = float(i)/float(numPoints)
		var remainingRatio: float = 1.0 - pointRatio
		var targetRatio = pathFollowNode.get_unit_offset()
		var behindFleet: bool = pointRatio < targetRatio
		var pointSizeScaleFactor = 30.0
		var pointSize = remainingRatio * pointSizeScaleFactor
		if behindFleet:
			pointColor.a = 0.05
		# seems like the baked curve has more points than we originally added into it.
		if i % 5 == 0:
			draw_circle(point, pointSize, pointColor)
		i+= 1




func _on_FleetDogfightZone_area_entered(area):
	# found another fleet. "Hey my fleet, go fight the other fleet".	
	
	if is_instance_valid(AssignedFleet) and is_instance_valid(area) and is_instance_valid(FactionObj):
		# verify that it's another ship first.
		var isFleetPathArea = area.owner.has_method("_on_FleetDogfightZone_area_entered")
		if isFleetPathArea and area.owner.FactionObj != self.FactionObj:
			var myFleet = AssignedFleet
			var enemyFleet = area.owner.AssignedFleet
			connect("encountered_enemy", myFleet, "_on_ShipPath_encountered_enemy")
			emit_signal("encountered_enemy", enemyFleet)
			disconnect("encountered_enemy", myFleet, "_on_ShipPath_encountered_enemy")
			#print("ShipPath encountered enemy. Signalling to Fleet")

func _on_planet_assigned_fleet(fleetObj):
	#AssignedFleets.push_back(fleetObj)
	AssignedFleet = fleetObj

func _on_planet_cannot_send_ships():
	# oh well, better luck next time. Either the planet has no units or it switched factions before you requested ships.
	die()

func _on_fleet_destroyed():
	die()
	
func _on_fleet_released():
	die()
	
