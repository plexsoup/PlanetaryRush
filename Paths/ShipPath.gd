extends Path2D

var last_point : Vector2
var min_point_separation : float = 50.0
var MyPlanet : StaticBody2D

enum States { DRAWING, FINISHED }
var State = States.DRAWING
var Faction : int # I wonder why are factions are integers instead of objects?
var CursorObj : Node2D
	
var FrameTicks = 0

signal finished_drawing(path)



func _ready():
	State = States.DRAWING
	last_point = Vector2.ZERO
	initialize_path()


func start(planet, faction, cursorObj):
	MyPlanet = planet
	CursorObj = cursorObj
	if faction == planet.Faction:
		Faction = faction
	else:
		print("Err: ShipPath -> planet faction does not match player faction")
	warp_to_planet(planet) # why?

func warp_to_planet(planet): 
	# relocate the cursor to the nearest planet, 
	# so the player can be sloppy with their inputs.
	if Faction == global.PlayerFaction:
		Input.warp_mouse_position(planet.get_global_transform_with_canvas().get_origin())

func end():
	$DestructionTimer.start()

func _on_DestructionTimer_timeout():
	self.set_curve(Curve2D.new())
	update()
	call_deferred("queue_free")

func _process(delta):
	update() # triggers _draw function
	#if FrameTicks % 250 == 0:
		#print("hi: " + str(FrameTicks) + " /t FrameTicks in " + self.name) 
		
	FrameTicks += 1
	


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
	


func finish_path():
	#if Faction == global.PlayerFaction:
	$MousePolling.stop()
	State = States.FINISHED
	connect("finished_drawing", MyPlanet, "_on_ShipPath_finished_drawing")
	connect("finished_drawing", CursorObj, "_on_ShipPath_finished_drawing")
	
	emit_signal("finished_drawing", self)

	disconnect("finished_drawing", MyPlanet, "_on_ShipPath_finished_drawing")
	disconnect("finished_drawing", CursorObj, "_on_ShipPath_finished_drawing")

	
func _on_MousePolling_timeout():
	if Faction == global.PlayerFaction:
		# add a point to the path
		if Input.is_action_pressed("left_click") and State == States.DRAWING:
			add_point()
		else:
			finish_path()
	else:
		if CursorObj.isStillDrawing():
			add_point()
		else:
			finish_path()
		
		
func _draw():
	var pathFollowNode = get_node("PathFollow2D")
	var myCurve = self.get_curve()
	var lineLength = myCurve.get_baked_length()
	var points = myCurve.get_baked_points()
	var numPoints = points.size()
	var i : int = 0
	for point in points:
		#Note: points have already been converted to_local for the draw function to work.
		var pointRatio: float = float(i)/float(numPoints)
		var remainingRatio: float = 1.0 - pointRatio
		var targetRatio = pathFollowNode.get_unit_offset()
		var behindFleet: bool = pointRatio < targetRatio
		
		var pointSizeScaleFactor = 30.0
		var pointSize = remainingRatio * pointSizeScaleFactor
		#var pointSize = float(numPoints - i + 1) / float(numPoints) * pointSizeScaleFactor
		
		var alpha : float = 0.0
		
		var factionColor = global.FactionColors[Faction]
		if Faction == global.PlayerFaction:
			factionColor.a = 0.5
		else:
			factionColor.a = 0.15
		if behindFleet:
			factionColor.a = factionColor.a / 2.0
		#draw_circle(to_local(point), pointSize, factionColor)
		draw_circle(point, pointSize, factionColor)
		
		i+= 1
		


