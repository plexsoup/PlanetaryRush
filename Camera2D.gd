extends Camera2D
# Intention: Zoom in, zoom out, move the view frustum toward the mouse cursor


# Declare member variables here. Examples:

var DesiredZoom = Vector2(1, 1)
var Ticks :int = 0

var MinZoom = 0.3
var MaxZoom = 4.5

onready var Cursor = get_node("..")

func _ready():
	DesiredZoom = zoom
	self.drag_margin_h_enabled = true
	self.drag_margin_v_enabled = true
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1
	
#	update()
#
#	if target != null:
#		position = target.position
#	else:
#		target = global.getPlayerShip()
		
	
	zoom = lerp(zoom, DesiredZoom, 0.2 * delta * 60)
	#print("zoom: ", str(zoom))

func _draw():
	#draw_string(global.BaseFont, Vector2(0, 20), "zoom: " + str(zoom), Color.antiquewhite )
	pass
	
func _input(event):
	if event is InputEventMouseButton and event.is_action("zoom_in"):
		DesiredZoom = zoom * 0.8
		var direction = -1
		#move_toward_mouse(direction)
		set_camera_drag_margins()
		
	if event is InputEventMouseButton and event.is_action("zoom_out"):
		DesiredZoom = zoom * 1.25
		var direction = 1
		#move_toward_mouse(direction)
		set_camera_drag_margins()

	DesiredZoom.x = clamp(DesiredZoom.x, MinZoom, MaxZoom)
	DesiredZoom.y = clamp(DesiredZoom.y, MinZoom, MaxZoom)

func move_toward_mouse(direction):
	# not the greatest feel, but it works ok for now
	pass
#	var myPos = get_global_position()
#	var cursorPos = Cursor.get_global_position()
#	#set_global_position(lerp(myPos, cursorPos, 0.8))

func set_camera_drag_margins():
	var drag = lerp(0, 1.0, (zoom.x - MinZoom) / (MaxZoom - MinZoom) )
	
	self.set_drag_margin(MARGIN_LEFT, drag)
	self.set_drag_margin(MARGIN_RIGHT, drag)
	self.set_drag_margin(MARGIN_TOP, drag)
	self.set_drag_margin(MARGIN_BOTTOM, drag)
	
	
	
	
	
	
	
