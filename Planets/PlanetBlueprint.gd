tool
extends Node2D


# Declare member variables here. Examples:
export var FactionNum : int = 0
export var Size : float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		var factionColors : PoolColorArray = [
			Color.blue, 
			Color.orangered, 
			Color.greenyellow, 
			Color.orange, 
			Color.lightseagreen, 
			Color.chocolate,
			Color.purple,
			Color.red, 
		]
		
		if FactionNum > -1:
			$Sprite.set_self_modulate(factionColors[FactionNum])
	else:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
