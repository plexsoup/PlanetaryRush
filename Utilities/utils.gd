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
	# can take any node2d or vector2
	# tolerance should be provided as percent: 0.0 to 1.0. Low more precise.
	
	# returns true if the destination is within distance or the target +/- tolerance
	if origin == null or destination == null:
		return false
		
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
	
	var withinProximity : bool = false
	var distanceToTarget = 0.0
	var fuzz = rand_range(-1.0*(float(distance)*tolerance),(float(distance)*tolerance))
	var desiredDistanceSq = pow(distance + fuzz, 2)
	if myPos.distance_squared_to(targetPos) < desiredDistanceSq:
		withinProximity = true
	
	return withinProximity

func GetRandElement(array):
	if typeof(array) != TYPE_ARRAY:
		return
	elif array.size() > 0:
		return(array[randi()%array.size()])
	else:
		return
