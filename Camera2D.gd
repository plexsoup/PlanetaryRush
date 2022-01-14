extends Camera2D
# Intention: Zoom in, zoom out, move the view frustum toward the mouse cursor


# Declare member variables here. Examples:

var DesiredZoom : Vector2
var Ticks :int = 0

var MinZoom = 0.3
var MaxZoom = 15.0


func _ready():
	
	
	self.drag_margin_h_enabled = false
	self.drag_margin_v_enabled = false
	
	

func start(levelObj, planetsObj):
	printerr("Camera2D.gd start() doesn't seem right.")
	#return
	# zoom extents to capture all the planets.
	
	var planets = planetsObj.get_all_planets()
	var AA = Vector2(1000000,1000000)
	var BB = Vector2(0, 0)

	var allX = []
	var allY = []
	
	for planet in planets:
		allX.push_back(planet.get_global_position().x)
		allY.push_back(planet.get_global_position().y)

	AA = Vector2(allX.min(),allY.min())
	BB = Vector2(allX.max(), allY.max())
	

	var extents : Rect2 = Rect2(AA, BB-AA)
	print("extents position = " + str(extents.position))
	print("extents size = " + str(extents.size))
	
	
	print("Camera2D.gd extents: " + str(extents))
	# ok, the rectangle should now include everything.
	# how do we turn that into camera scale?

	self.set_offset(extents.position + (extents.size / 2.0))
	#self.set_offset(extents.position)
	
	# what's the viewport size?
	# compare that to the required rect2
	# then set the zoom (bigger numbers zoom out, smaller zoom in)
	var viewport = get_viewport()
	var viewportToRectRatio = viewport.size.x * (1/extents.size.x * 2)
	print("Camera2D.gd" + str(viewportToRectRatio))
#	DesiredZoom = Vector2(viewportToRectRatio, viewportToRectRatio) # ??? Guess? some relationship to viewport size and extents size
	DesiredZoom = extents.size / 250
	
	
	
	# get the AABB rect2 which includes all the planets.
	# move the camera origin to the center of mass
	# set the camera scale to include every planet in the viewport
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	zoom = lerp(zoom, DesiredZoom, 0.2 * delta * 60)
	
	check_for_keyboard_movement(delta)
	
func check_for_keyboard_movement(delta):
	var scrollSpeed = 800.0 * delta
	if Input.is_action_pressed("ui_up"):
		offset.y -= scrollSpeed
	if Input.is_action_pressed("ui_left"):
		offset.x -= scrollSpeed
	if Input.is_action_pressed("ui_right"):
		offset.x += scrollSpeed
	if Input.is_action_pressed("ui_down"):
		offset.y += scrollSpeed
	
	
	

func _draw():
	#draw_string(global.BaseFont, Vector2(0, 20), "zoom: " + str(zoom), Color.antiquewhite )
	pass
	
func _input(event):
	if event is InputEventMouseButton and event.is_action("zoom_in"):
		DesiredZoom = zoom * 0.8
		var direction = -1
		#move_toward_mouse(direction)


	if event is InputEventMouseButton and event.is_action("zoom_out"):
		DesiredZoom = zoom * 1.25
		var direction = 1
		#move_toward_mouse(direction)


	if event is InputEventKey and event.is_action("ui_up"):
		pass # we'll do this in _process instead. if is_action_pressed

	DesiredZoom.x = clamp(DesiredZoom.x, MinZoom, MaxZoom)
	DesiredZoom.y = clamp(DesiredZoom.y, MinZoom, MaxZoom)

func move_toward_mouse(direction):
	# not the greatest feel, but it works ok for now
	var myPos = get_global_position()
	#var cursorPos = Cursor.get_global_position()
	var mousePos = get_global_mouse_position()
	set_global_position(lerp(myPos, mousePos, 0.8))

func set_camera_drag_margins():
	var drag = lerp(0, 1.0, (zoom.x - MinZoom) / (MaxZoom - MinZoom) )
	
	self.set_drag_margin(MARGIN_LEFT, drag)
	self.set_drag_margin(MARGIN_RIGHT, drag)
	self.set_drag_margin(MARGIN_TOP, drag)
	self.set_drag_margin(MARGIN_BOTTOM, drag)
	
	
	
	
	
	
	
