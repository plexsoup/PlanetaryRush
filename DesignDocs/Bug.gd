extends Reference


# Declare member variables here. Examples:
var Category : String = "Bug" # could be MaybeSomeday, Design, etc
var ID : String = "" # 
var Title : String
var Details : String
var Priority : String # high, medium, low
var Dependencies : Array # list of other bugs
var DateCreated : Dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(category, id, title, details, priority, dependencies, dateCreated):
	Category = category
	ID = id
	Details = details
	Priority = priority
	Dependencies = dependencies
	DateCreated = dateCreated
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
