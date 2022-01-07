extends OptionButton

var sizes = [ Vector2(1920, 1080), Vector2(1024, 768), Vector2(800, 600)  ]

func _ready():
	for size in sizes:
		add_item(str(size.x) + "x" + str(size.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ResolutionList_item_selected(ID):
	OS.set_window_size(sizes[ID])