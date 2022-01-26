
extends Node

export var CheckMarkButtonTex : StreamTexture
export var DeleteIconTex : StreamTexture
export var UpArrowTex : StreamTexture
export var DownArrowTex : StreamTexture
export var PencilTex : StreamTexture

var BugActionButtonTextures = {}

var DetailTextBox
var BuglistTreeObj : Tree

var BugResource = preload("res://DesignDocs/bug_resource.tres")

var BugCollection : Array = [] # resource objects to manipulate bugs

var JSONBugList

#var Columns = ["id", "title", "details", "actions"]
#var ColDetails = {
#	"id":{"width":75, "expand":false, "editable":false},
#	"title":{"width":225, "expand":false, "editable":true},
#	"details":{"width":425, "expand":true, "editable":true},
#	"actions":{"width":250, "expand":false, "editable":false},
#}

var BugProperties = ["Category", "Id", "Title", "Details", "Priority", "Dependencies", "DateCreated", "Actions"]
var Columns = ["Category", "Id", "Title", "Details", "Priority", "Dependencies", "DateCreated", "Actions"]
var ColDetails = {
	"Category":{"width":75, "expand":false, "editable":false},
	"Id":{"width":25, "expand":false, "editable":false},
	"Title":{"width":150, "expand":false, "editable":true},
	"Details":{"width":200, "expand":true, "editable":true},
	"Priority":{"width":75, "expand":false, "editable":true},
	"Dependencies":{"width":25, "expand":false, "editable":false},
	"DateCreated":{"width":55, "expand":false, "editable":false},
	"Actions":{"width":85, "expand":false, "editable":false},
}

signal finished

func _ready():
	if get_tree().get_root().get_children().has(self): # running scene solo
		call_deferred("start", [null])
	else: # running scene in the game
		pass
		# The main menu will call start when the user requests it

func start(callbackObj):
	BugActionButtonTextures = {
		"Delete" : DeleteIconTex,
		"Move to top": UpArrowTex,
		"Move to bottom": DownArrowTex,
		"Edit" : PencilTex,
	}

	setPanelSize()
	
	
	var jsonBugList = loadBugList("user://saved_buglist.dat")
	var buglist = generateBugCollection(jsonBugList)
	var tree = createTree()
	populateTree(tree, buglist, "category")
	BugCollection = buglist

func setPanelSize():
	var viewportSize = get_viewport().get_size()
	self.rect_size = viewportSize

func populateTree(treeNode : Tree, collectionOfBugs : Array, groupBy : String) -> void:
	find_node("GroupingLabel", true).set_text(groupBy)
	var rootItem = treeNode.get_root()
	var groupMembersCollection = []
	for bug in collectionOfBugs:
		if not groupMembersCollection.has(bug.get(toPythonCase(groupBy))):
			groupMembersCollection.push_back(bug.get(toPythonCase(groupBy)))
	
	for grouping in groupMembersCollection:
		var groupItem = treeNode.create_item(rootItem)
		groupItem.set_text(0, str(grouping))
	
		for bug in collectionOfBugs:
			if bug.get(groupBy.capitalize()) == grouping:
				var bugItem = treeNode.create_item(groupItem)
				
				var i = 0
				for columnName in Columns:
					if columnName != "Actions":
						var cellText = bug.get(toPythonCase(columnName))
						if cellText == null:
							cellText = ""
						bugItem.set_text(i, str(cellText))
						bugItem.set_editable(i, ColDetails[columnName]["editable"])
						i += 1
				addButtons(bugItem, 7)
	
func addButtons(treeItem, column):
	
	var i = 0
	for texture in BugActionButtonTextures.values():
		var disabled = false
		var tooltip = BugActionButtonTextures.keys()[i]
#		treeItem.add_button(column, BugActionButtonTextures[i], i, disabled, str(BugActionButtonIndex.keys()[i]) )
		treeItem.add_button(column, texture, i, disabled, tooltip )
		i += 1
	
	
func createTree() -> Tree:
	var marginBox = MarginContainer.new()
	marginBox.set_name("MarginBox")
	marginBox.margin_left = 10
	marginBox.margin_right = get_viewport().size.x
	marginBox.margin_bottom = get_viewport().size.y
	marginBox.anchor_left = 1
	marginBox.anchor_right = 1
	$VBoxContainer/BuglistPanel.add_child(marginBox)
	var tree = Tree.new()
	tree.set_name("Buglist Tree")
	
	tree.set_columns(Columns.size() ) 
	
	for colNum in Columns.size():
		tree.set_column_expand(colNum, ColDetails[Columns[colNum]]["expand"])
		tree.set_column_min_width(colNum, ColDetails[Columns[colNum]]["width"])
		tree.set_column_title(colNum, Columns[colNum])
	tree.set_select_mode(tree.SELECT_SINGLE)
	tree.set_column_titles_visible(true)
	
	
	
	tree.connect("button_pressed", self, "_on_tree_button_pressed")
	tree.connect("item_edited", self, "_on_Tree_item_edited")
	tree.connect("column_title_pressed", self, "_on_Tree_column_title_pressed")

	marginBox.add_child(tree)
	BuglistTreeObj = tree
	var root = tree.create_item()
	tree.set_hide_root(false)
	



	return tree






func converGroupsToTable(nestedBuglistDict : Dictionary) -> Dictionary:
	var tempFlatBuglistDict = {}
	var categories = []
	var id = 0
	for categoryName in nestedBuglistDict.keys(): # top level categories
		categories.push_back(categoryName)
		for bug in nestedBuglistDict[categoryName]:
			tempFlatBuglistDict[id] = bug
			tempFlatBuglistDict[id]["category"] = categoryName
			tempFlatBuglistDict[id]["refID"] = id
			tempFlatBuglistDict[id]["priority"] = "medium"
			id += 1
	
	return tempFlatBuglistDict
	

	

	

func jsonifyBuglist() -> String :
	var blDict = {}
	var jsonBuglist = ""
	#var cols = ["Category", "ID", "Title", "Details", "Priority", "Dependencies", "DateCreated"]
	for bug in BugCollection:
		blDict[bug.ID] = {
			"Category" : bug.Category,
			"ID" : bug.ID,
			"Title" : bug.Title,
			"Details" : bug.Details,
			"Priority" : bug.Priority,
			"Dependencies" : bug.Dependencies,
			"DateCreated" : bug.DateCreated,
		}
	jsonBuglist = JSON.print(blDict, "\t")
	return jsonBuglist


func saveBugList(path):
	print("Saving Buglist to JSON file: " + path)
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(jsonifyBuglist())
	file.close()

func loadBugList(path) -> String : # Loads JSON from a file
	# does not populate the tree
	
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	var bugList = generateBugCollection(content) # now we have a BugCollection array containing a resource for each bug
	return content 

func generateBugCollection(jsonBugList:String) -> Array:
	var bugCollection : Array = []
	var parseResult : JSONParseResult = JSON.parse(jsonBugList)
	var tempBuglist : Dictionary = parseResult.result
	
	# if the dictionary is multi-level?

	
	var i : int = 0
	for bugItem in tempBuglist.values():
		var bug = BugResource.duplicate()
		for propertyName in Columns:
			if propertyName != "Actions": # buttons don't have properties in the buglist
				var propertyNamePC = toPythonCase(propertyName)
				if bugItem.has(propertyName): # lower case?
					bug.set(toPythonCase(propertyNamePC), bugItem[propertyName])
				elif bugItem.has(propertyNamePC): # capitalized
					bug.set(propertyNamePC, bugItem[propertyNamePC])
				else:
					printerr("DesignNotes.gd: we have a problem in generateBugCollection")
					print("propertyName == " + propertyName + ". propertyNamePC == " + propertyNamePC)
			# careful with capitalize(). it'll add spaces. May want to use one-word titles
		bugCollection.push_back(bug)
		i += 1

	return bugCollection

func toPythonCase(propertyName) -> String :
	# we want to convert any string to PythonCase so we can reference property varialbes with set/get
	var pythonCasifiedString = ""
	propertyName = propertyName.capitalize() # capitalize adds spaces
	var words = propertyName.split(" ")
	for word in words:
		pythonCasifiedString += word
	
	return pythonCasifiedString


func prettyPrintBugs(bugCollection : Array):
	for bug in bugCollection:

		print("ID: " + str(bug.ID))
		print("Category: " + str(bug.Category))
		print("Title: " + str(bug.Title))
		print("Details: " + str(bug.Details))
		print("Priority: " + str(bug.Priority))
		print("Dependencies: " + str(bug.Dependencies))
		print("Date Created: " + str(bug.DateCreated))
		print("-----------------------------------")

func isDictNested(dict : Dictionary):
	
	# this is failing..	
	var isNested : bool = false
	
	if dict.keys().find("0") > -1:
		return false
	else:
		return true

#	for value in dict.values():
#
#		# if any of the top-level entries contain another dictionary
#		if typeof(value) == TYPE_DICTIONARY:
#			isNested = true
#	return isNested
	




func References():
	pass
	
"""
Other awesome godot project management tools:
	https://github.com/godotengine/awesome-godot#projects

Node Conquest games:
- Galcon
- Dominari Empires
- Eufloria
- Ghost in the Cell on codingame.com
- R.O.O.T.S.
- many newgrounds games: Phage Wars/Tentacle Wars/Civilization Wars/Virus Wars
- FreeOrion
- Auralux
- micro wars by kalt
- phage wars
- oil rush
- microcosmum
- city takeover on google app store
- bug war, tentacle war, civilization wars, little stars for little wars

TBS Games with bases
- hex empire
- master of magic
- master of orion

Line-Drawing games
- flight control, etc.

"""

func getBug(bugID):
	var relevantBug
	for bug in BugCollection:
		if bug.ID == bugID:
			relevantBug = bug
	return relevantBug

func deleteBug(bug):
	# bugs are resources stored in an array.
	# resources don't have a queue_free() or free()
	# Resource extends from Reference. As such, when a resource is no longer in use, it will automatically free itself.
	BugCollection.erase(bug)
	

func _on_Tree_column_title_pressed(column):
	var label = $VBoxContainer/HSplitContainer/PanelContainer/LeftHBox/GroupingLabel
	var text = Columns[column]
	var enabled = ["category", "priority", "date"]
	if enabled.has(text):
		label.set_text(text)
	BuglistTreeObj.clear()
	populateTree(BuglistTreeObj, BugCollection, text)

func _on_tree_button_pressed(item, column, button_id):
	var tooltip = item.get_button_tooltip(column, button_id)
	#print("pressed button: " + tooltip + " on item: " + item.get_text(Columns.find("title")))
	print("pressed button: " + tooltip + " on item: " + item.get_text(Columns.find("Title")))
	
	var bugID = int(item.get_text(Columns.find("Id")))
	var bug = getBug(bugID)
	
	if tooltip == "Delete":
		#print(bug.Title + " scheduled for deletion ")
		deleteBug(bug)
		item.free()
	elif tooltip == "Move to top":
		# not sure how to make this persistent
		item.move_to_top()
	elif tooltip == "Move to bottom":
		# not sure how to make this persistent. Need a DisplayOrderID
		item.move_to_bottom()
	elif tooltip == "Edit":
		var dialog = $Dialogs/EditBugPopup
		dialog.popup_centered()
		populateBugDialog(dialog, bugID)


func _on_SaveButton_pressed():
	$Dialogs/SaveDialog.popup_centered()

func _on_LoadButton_pressed():
	$Dialogs/LoadDialog.popup_centered()


func _on_LoadDialog_file_selected(path):
	JSONBugList = loadBugList(path)
	BuglistTreeObj.clear()
	populateTree(BuglistTreeObj, generateBugCollection(JSONBugList), "category")
	


func _on_SaveDialog_file_selected(path):
	saveBugList(path)


func _on_Tree_item_edited(): # only fires after user hits return or leaves the cell.
	var editedItem = BuglistTreeObj.get_edited()
	print("edited: " + str(editedItem))
	
	var bugID = int(editedItem.get_text(Columns.find("Id")))
	var bug = getBug(bugID)
	
	bug.Title = editedItem.get_text(Columns.find("Title"))
	bug.Details = editedItem.get_text(Columns.find("Details"))
#	print(bug.Title)
#	print(bug.Details)
	

func getNewBugID() -> int:
	var existingIDs = []
	for bug in BugCollection:
		existingIDs.push_back(bug.ID)
	return existingIDs.max()+1

func createBug() -> Resource:
	var bug = BugResource.duplicate()	
	bug.ID = getNewBugID()
	return bug
	
func populateBugDialog(dialog, bugID):
	var tree = dialog.find_node("Tree")
	var bug
	
	if bugID == -1:
		bug = createBug()
	else:
		bug = getBug(bugID)
	
	var root = tree.create_item()
	for property in bug.get_property_list():
		var newItem = tree.create_item(root)
		newItem.set_text(0, property["name"])
		newItem.set_text(1, str(bug.get(property["name"])))
		newItem.set_editable(1, true)
		
	
	

func _on_NewBugButton_pressed():
	print("New Bug Button Pressed")
	var dialog = $Dialogs/EditBugPopup
	dialog.popup_centered()
	populateBugDialog(dialog, -1)
	


func _on_DiscardBugBtn_pressed():
	# close the modal dialog box for creating a new bug or editing an existing bug
	$Dialogs/EditBugPopup.hide()

