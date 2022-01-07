extends OptionButton

func _ready():
	add_item("Easy")
	add_item("Medium")
	add_item("Hard")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_DifficultyButton_item_selected(ID):
	global.options["difficulty"] = ID
	
func start():
	select(global.options["difficulty"])


func _on_DifficultyButton_visibility_changed():
	start()
