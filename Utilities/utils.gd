extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func WithinFuzzyProximity(origin, destination, distance, tolerance):
	randomize()

	var withinProximity : bool = false
	# can take any node2d or vector2
	# tolerance should be provided as percent: 0.0 to 1.0. Low more precise.
		
	var myPos : Vector2
	var targetPos : Vector2
	if typeof(origin) == TYPE_OBJECT: # ie: not TYPE_VECTOR2
		if origin.has_method("get_global_position"):
			myPos = origin.get_global_position()
		else:
			myPos = origin
	if typeof(destination) == TYPE_OBJECT:
		if destination.has_method("get_global_position"):
			targetPos = destination.get_global_position()
		else:
			targetPos = destination
	
	var fuzz = rand_range(-1.0*(float(distance)*tolerance),(float(distance)*tolerance))
	#print("fuzz = " + str(fuzz) + " , distance = " + str(distance))
	var desiredDistanceSq = (distance + fuzz) * (distance + fuzz)
	if myPos.distance_squared_to(targetPos) < desiredDistanceSq:
		withinProximity = true
	
	return withinProximity

func GetRandElement(array):
	var acceptableTypes = [TYPE_ARRAY, TYPE_VECTOR2_ARRAY, TYPE_DICTIONARY]
	if not acceptableTypes.has(typeof(array)):
		printerr("GetRandElement got a type it didn't expect")
		return
	elif array.size() > 0:
		return(array[randi()%array.size()])
	else:
		return
