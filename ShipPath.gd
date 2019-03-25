extends Path2D

var last_point : Vector2
var min_point_separation : float = 15.0
var MyPlanet : StaticBody2D

enum States { DRAWING, FINISHED }
var State = States.DRAWING
var Faction : int

signal finished_drawing(path)



func _ready():
	State = States.DRAWING
	last_point = Vector2.ZERO
	initialize_path()


func start(planet):
	MyPlanet = planet
	Faction = planet.Faction

func end():
	$DestructionTimer.start()

func _on_DestructionTimer_timeout():
	self.set_curve(Curve2D.new())
	update()
	call_deferred("queue_free")

func _process(delta):
	update()


func initialize_path():
	var newCurve = Curve2D.new()
	set_curve(newCurve)
	
	# added to scene in inspector
#	var newPath = PathFollow2D.new()
#	#newPath.name = "PathFollow2D"
#	add_child(newPath)

func add_point():
	var mousePos = get_local_mouse_position()
	if last_point.distance_squared_to(mousePos) > min_point_separation * min_point_separation:
		self.get_curve().add_point(mousePos)
		last_point = mousePos
	$MousePolling.start()


func finish_path():
	$MousePolling.stop()
	State = States.FINISHED
	connect("finished_drawing", MyPlanet, "_on_ShipPath_finished_drawing")
	connect("finished_drawing", global.cursor, "_on_ShipPath_finished_drawing")
	
	emit_signal("finished_drawing", self)

	disconnect("finished_drawing", MyPlanet, "_on_ShipPath_finished_drawing")
	disconnect("finished_drawing", global.cursor, "_on_ShipPath_finished_drawing")
	
	
func _on_MousePolling_timeout():
	# add a point to the path
	if Input.is_action_pressed("left_click") and State == States.DRAWING:
		add_point()
	else:
		finish_path()
		
		
		
func _draw():
	for point in self.get_curve().get_baked_points():
		var factionColors = [ Color.gray, Color(0.6, 0.6, 1.0, 0.25), Color(1.0, 0.6, 0.6, 0.25)]
		draw_circle(point, 3, factionColors[Faction])




