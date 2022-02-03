tool
extends Node2D


# Declare member variables here. Examples:
export var FactionNum : int = -1 setget set_faction_num
export var Size : float = 1.0 setget set_planet_size


# Called when the node enters the scene tree for the first time.
func _ready():
	if inGame():
		pass
		#set_faction_num(-1)
	elif inEditor():
		pass
		#set_planet_size(Size)
		#set_faction_num(-1)

func inEditor():
	return Engine.is_editor_hint()
	
func inGame():
	return not Engine.is_editor_hint()


func set_planet_size(size):
	$Sprite.set_scale(Vector2(float(size), float(size)))
	Size = size

func set_faction_num(factionNum):
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

		if factionNum > -2 and factionNum < factionColors.size():
		
			if factionNum > -1:
				$Sprite.set_self_modulate(factionColors[factionNum])
			elif factionNum == -1:
				$Sprite.set_self_modulate(Color.white)
				
			FactionNum = factionNum
		else:
			printerr(self.name + ": PlanetBlueprint.gd: FactionNum outside bounds")
	

