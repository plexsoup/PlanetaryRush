extends Tabs

var CurrentTab = 0
var NumTabs : int
onready var PageContainer = $Margin/VBoxContainer/TabContainer
onready var PageCounter = $Margin/VBoxContainer/Navigation/PageCount

# Called when the node enters the scene tree for the first time.
func _ready():
	NumTabs = PageContainer.get_child_count()
	showPageCount()

func showPageCount():
	PageCounter.set_text(str(CurrentTab + 1) + " of " + str(NumTabs))
	

func advanceSlide(number):
	
	CurrentTab = wrapi(CurrentTab + number, 0, NumTabs)
	PageContainer.set_current_tab(CurrentTab)
	showPageCount()
	
func _on_BackButton_pressed():
	advanceSlide(-1)


func _on_ForwardButton_pressed():
	advanceSlide(1)
