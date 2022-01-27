extends Reference


# Declare member variables here. Examples:
export var Category : String = "Bug" # could be MaybeSomeday, Design, etc
export var Id : int # 
export var Title : String
export var Details : String
export var Priority : String # high, medium, low
export var Dependencies : Array # list of other bugs
export var DateCreated : int # in unix_time because I don't want to store another dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(category, id, title, details, priority, dependencies, dateCreated):
	Category = category
	Id = id
	Details = details
	Priority = priority
	Dependencies = dependencies
	DateCreated = dateCreated
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
