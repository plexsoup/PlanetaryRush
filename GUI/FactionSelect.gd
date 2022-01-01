extends ItemList

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	select(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FactionSelect_item_selected(index):
	print(self.name, " chose index: ", index)
	global.PlayerFactionNum = index+1 # 0 is reserved for Gray
	
