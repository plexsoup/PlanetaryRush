extends Camera2D

# Declare member variables here. Examples:

var DesiredZoom = Vector2(1, 1)
var Ticks :int = 0

var MinZoom = 0.3
var MaxZoom = 4.5

onready var Cursor = get_node("..")

func _ready():
	DesiredZoom = zoom
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
		move_toward_mouse(-1)
	if event is InputEventMouseButton and event.is_action("zoom_out"):
		DesiredZoom = zoom * 1.25
		move_toward_mouse(1)

	DesiredZoom.x = clamp(DesiredZoom.x, MinZoom, MaxZoom)
	DesiredZoom.y = clamp(DesiredZoom.y, MinZoom, MaxZoom)

func move_toward_mouse(direction):
	# not the greatest feel, but it works ok for now
	
#	var myPos = get_global_position()
#	var cursorPos = Cursor.get_global_position()
#	#set_global_position(lerp(myPos, cursorPos, 0.8))
	
	var drag = lerp(0, 1.0, (zoom.x - MinZoom) / (MaxZoom - MinZoom) )
	drag_margin_bottom = drag
	drag_margin_left = drag
	drag_margin_top = drag
	drag_margin_right = drag
	
	
	
	
	
	