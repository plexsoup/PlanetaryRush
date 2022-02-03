# current work effort:
# fix new/edit bug dialog. It's broken in all kinds of ways
# fix grouping when you click a column title: messes up the root node


extends Node

export var CheckMarkButtonTex : StreamTexture
export var DeleteIconTex : StreamTexture
export var UpArrowTex : StreamTexture
export var DownArrowTex : StreamTexture
export var PencilTex : StreamTexture

var BugActionButtonTextures = {}

var DetailTextBox
var BuglistTreeObj : Tree
var GroupBy : String = "Category"

var BugResource = preload("res://DesignDocs/bug_resource.tres")

var BugCollection : Array = [] # resource objects to manipulate bugs

onready var EditBugPopup = $Dialogs/EditBugPopup
onready var BugEditTreeNode = $Dialogs/EditBugPopup/MarginContainer/VBoxContainer/BugEditTree

var JSONBugList
var DefaultSaveFilePath = "saved_buglist.dat"

var TempCounter : int = 0

enum Noises {CLICK, HOVER, ERROR}



var BugProperties = ["Category", "Id", "Title", "Details", "Priority", "Dependencies", "DateCreated"]
var Columns = ["Category", "Id", "Title", "Details", "Priority", "Dependencies", "DateCreated", "Actions"]
var ColDetails = {
	"Category":{"width":75, "expand":false, "editable":false, "sortable":true},
	"Id":{"width":25, "expand":false, "editable":false, "sortable":true},
	"Title":{"width":150, "expand":false, "editable":true, "sortable":true},
	"Details":{"width":100, "expand":true, "editable":true, "sortable":false},
	"Priority":{"width":75, "expand":false, "editable":true, "sortable":true},
	"Dependencies":{"width":25, "expand":false, "editable":false, "sortable":false},
	"DateCreated":{"width":55, "expand":false, "editable":false, "sortable":true},
	"Actions":{"width":85, "expand":false, "editable":false, "sortable":false},
}

signal finished

func _ready():
	if runningSceneSolo():
		call_deferred("start", [null])
	else: # running scene in the game
		pass
		# The main menu will call start when the user requests it

func start(callbackObj):
	var nodesDict = nodesToDict(self) # before you add any other nodes
	#print(nodesDict)
	# print(nodesDictToCode(nodesDict[self.name]))

	BugActionButtonTextures = {
		"Move to top": UpArrowTex,
		"Move to bottom": DownArrowTex,
		"Edit" : PencilTex,
	}

	setPanelSize()
	
	
	var jsonBugList = loadBugList("user://" + DefaultSaveFilePath)
	var buglist = generateBugCollection(jsonBugList)
	var tree = createTree()
	populateTree(tree, buglist, GroupBy)
	BugCollection = buglist
	
	
func getAllNodes(node) -> String:
	var returnStr = ""
	for N in node.get_children():
		if N.get_child_count() > 0:
			if not N.get_name().begins_with("@"):
				returnStr = returnStr + "\n\t["+N.get_name()+"]"
				returnStr = returnStr + getAllNodes(N)
		else:
			# Do something
			if not N.get_name().begins_with("@"):
				returnStr = returnStr + "\n\t- "+N.get_name()
	return returnStr

func runningSceneSolo():
	# determine if the scene is running alone (play scene), or within the context of a full game.
	return get_tree().get_root().get_children().has(self)

func nodesToDict(nodes): # may return a dictionary or null
	if nodes == null:
		return null
		
	var nodeArr = []
	if typeof(nodes) == TYPE_ARRAY:
		nodeArr.append_array(nodes)
	else:
		nodeArr.push_back(nodes)
	# recursive function to walk a node tree and return a dictionary
	# useful for running code to spawn the same nodes procedurally later
	# like in a plugin

	var nodesDict = {}
	
	for node in nodeArr:
		if not node.get_name().begins_with("@"):
			nodesDict[node.name] = {
				"name" : node.name,
				"type" : node.get_class(),
				"children" : nodesToDict(node.get_children()),
			}
	return nodesDict

func nodesDictToCode(nodesDict, i=0):
	if i > 100:
		printerr("BugList.gd: nodesDictToCode(): recursive function getting a bit too large")
		return
	var gdScriptCodeStr = ""
	if typeof(nodesDict) == TYPE_DICTIONARY:
		for nodeName in nodesDict.keys():
			gdScriptCodeStr += "\nvar node"+ str(i) +" = " + nodesDict["type"] + ".new()"
			
			gdScriptCodeStr += "\nnode"+ str(i) + ".name = " + '"' +nodesDict["name"] + '"'

			gdScriptCodeStr += "\nnode"+ str(i) + ".add_child(node"+ str(i) +")"
			
			if typeof(nodesDict["children"]) == TYPE_DICTIONARY:
				for childName in nodesDict["children"].keys():
					gdScriptCodeStr += nodesDictToCode(nodesDict["children"][childName], i+1)
			i += 1
	elif typeof(nodesDict) == TYPE_STRING:
		print("nodesDictToCode(): "+ nodesDict )
		

	
	return gdScriptCodeStr
	

func setPanelSize():
	var viewportSize = get_viewport().get_size()
	self.rect_size = viewportSize

func populateTree(treeNode : Tree, collectionOfBugs : Array, groupBy : String) -> void:
	printerr("bug in populateTree: if you group by Category, ID doesn't show up")
	treeNode.clear()
	find_node("GroupingLabel", true).set_text(groupBy)
	var rootItem = treeNode.create_item()
	treeNode.set_hide_root(true)
	#var rootItem = treeNode.get_root()
	var groupMembersCollection = []
	for bug in collectionOfBugs:
		if not groupMembersCollection.has(bug.get(toPythonCase(groupBy))):
			groupMembersCollection.push_back(bug.get(toPythonCase(groupBy)))
	
	for grouping in groupMembersCollection:
		var groupItem = treeNode.create_item(rootItem)
		groupItem.set_text(0, str(grouping))
		groupItem.set_expand_right(0, true)
		populateGroupRows(treeNode, collectionOfBugs, grouping, groupBy, groupItem)

func populateGroupRows(treeNode, collectionOfBugs, grouping, groupBy, groupItem):
	for bug in collectionOfBugs:
		if bug.get(groupBy.capitalize()) == grouping:
			var bugItem = treeNode.create_item(groupItem)
			
			var colNum = 0
			for columnName in Columns:
				if columnName != groupBy:
					var cellText = bug.get(toPythonCase(columnName))
					if cellText == null:
						cellText = ""
					bugItem.set_text(colNum, str(cellText))
					bugItem.set_editable(colNum, ColDetails[columnName]["editable"])
					treeNode.set_column_expand(colNum, ColDetails[columnName]["expand"])
					treeNode.set_column_min_width(colNum, ColDetails[columnName]["width"])
					treeNode.set_column_title(colNum, columnName)
				colNum += 1
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





## appears to be unused?
#func convertGroupsToTable(nestedBuglistDict : Dictionary) -> Dictionary:
#	var tempFlatBuglistDict = {}
#	var categories = []
#	var id = 0
#	for categoryName in nestedBuglistDict.keys(): # top level categories
#		categories.push_back(categoryName)
#		for bug in nestedBuglistDict[categoryName]:
#			tempFlatBuglistDict[id] = bug
#			tempFlatBuglistDict[id]["category"] = categoryName
#			tempFlatBuglistDict[id]["refId"] = id
#			tempFlatBuglistDict[id]["priority"] = "medium"
#			id += 1
#
#	return tempFlatBuglistDict
	


func jsonifyBuglist() -> String :
	print("BugList.gd starting jsonifyBuglist. BugCollection.size() == " + str(BugCollection.size()))
	var blDict = {}
	var jsonBuglist = ""
	#var cols = ["Category", "Id", "Title", "Details", "Priority", "Dependencies", "DateCreated"]

	for bug in BugCollection:
#		if bug.Id == 0:
#			bug.Id = getNewBugId()
		blDict[str(bug.Id)] = {
			"Category" : bug.Category,
			"Id" : bug.Id,
			"Title" : bug.Title,
			"Details" : bug.Details,
			"Priority" : bug.Priority,
			"Dependencies" : bug.Dependencies,
			"DateCreated" : bug.DateCreated,
		}
	
	jsonBuglist = JSON.print(blDict, "\t")
	return jsonBuglist


func saveBugList(path):
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
	if parseResult.result == null:
		return []
		
	var tempBuglist : Dictionary = parseResult.result
	
	# if the dictionary is multi-level?

	
	var i : int = 0
	for bugItem in tempBuglist.values():
		if bugItem.has("ID"):
			if bugItem["ID"] == null:
				bugItem["ID"] == getNewBugId()
		elif bugItem.has("Id"):
			if bugItem["Id"] == null:
				bugItem["Id"] == getNewBugId()
		var bug = BugResource.duplicate()
		for propertyName in bugItem.keys(): # was columns
			if propertyName != "Actions": # buttons don't have properties in the buglist
				if bugItem.has(propertyName): # most cases. Don't mess with the string's case
					bug.set(propertyName, bugItem[propertyName])
				elif bugItem.has(toPythonCase(propertyName)): # Python Case (eg: DateCreated)
					bug.set(toPythonCase(propertyName), bugItem[propertyName])
				elif bugItem.has(propertyName.to_upper()): # Upper Case (eg: Id)
					bug.set(propertyName.to_upper(), bugItem[propertyName])
				else:
					printerr("DesignNotes.gd: we have a problem in generateBugCollection")
					print("propertyName == " + propertyName + " no PythonCase nor ALLCAPS found in bug_resource.tres/bug.gd")
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
		for property in bug.get_property_list():
			print(property["name"] + ": " + bug.get(property["name"]))


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

func getBug(bugId):
	var relevantBug = null
	for bug in BugCollection:
		if int(bug.Id) == int(bugId):
			relevantBug = bug
	return relevantBug

func deleteBug(bug):
	# bugs are resources stored in an array.
	# resources don't have a queue_free() or free()
	# Resource extends from Reference. As such, when a resource is no longer in use, it will automatically free itself.
	BugCollection.erase(bug)

func getNewBugId() -> int:
	var existingIds = []
	if BugCollection.size() > 0:
		for bug in BugCollection:
			existingIds.push_back(bug.Id)
		return existingIds.max()+1
	else:
		TempCounter += 1
		return TempCounter


func createBug(idNum : int = -1) -> Resource:
	
	var bug = BugResource.duplicate()
	if idNum == -1:
		bug.Id = getNewBugId()
	else:
		bug.Id = idNum
	return bug
	
func populateBugDialog(dialog, bugId):
	var tree = BugEditTreeNode
	var bug
	
	if bugId == -1:
		bug = createBug()
	else:
		bug = getBug(bugId)
	
	var root = tree.create_item()
	tree.set_hide_root(true)
	for property in BugProperties:
		var newItem = tree.create_item(root)
		newItem.set_text(0, property) # col 0 is the name of the property (aka key, title, label)
		newItem.set_text(1, str(bug.get(property))) # col 1 is the value of the property
		newItem.set_editable(1, true)
		
func saveBugFromDialog():
	# read all the items in the table
	var dialog = $Dialogs/EditBugPopup
	var tree = BugEditTreeNode
	var root = tree.get_root()
	
	var tempProperties = {}
	var treeItem = root.get_children()
	tempProperties[treeItem.get_text(0)] = treeItem.get_text(1) 

	var EoF = false
	var i = 0
	var nextItem = root.get_children()
	while not EoF and i < 100:
		if nextItem == null:
			EoF = true
		else:
			print("nextItem property = "+nextItem.get_text(0) + " value == "+ nextItem.get_text(1) )
			tempProperties[str(nextItem.get_text(0))] = nextItem.get_text(1)
			nextItem = nextItem.get_next()
		i += 1
	
	var bug = getBug(int(tempProperties["Id"]))
	if bug == null:
		bug = createBug(int(tempProperties["Id"]))
	for property in tempProperties.keys():
		bug.set(property, tempProperties[str(property)])
	BugCollection.push_back(bug)
	populateTree(BuglistTreeObj, BugCollection, GroupBy)
	dialog.hide()

func treeTableFind(tree, column, text):
	# return the treeItem (row) with the given text in the given column
	# walk the tree and return the corresponding field
	# Alternative approach would be to use the gdscript built-in call_recursive() function for TreeItems
	var item = tree.get_root().get_children()
	var EoF = false
	var itemFound = false
	while not EoF and not itemFound:
		if item == null:
			EoF = true
			return null
		elif item.get_text(column) == text:
			itemFound = true
			return item
		else:
			item = item.get_next()

func makeNoise(noiseEnum):
	if noiseEnum == Noises.CLICK:
		$Audio/ClickNoise.play()
	elif noiseEnum == Noises.ERROR:
		$Audio/ErrorNoise.play()
	elif noiseEnum == Noises.HOVER:
		$Audio/HoverNoise.play()


########################################################################
# Signals


func _on_Tree_column_title_pressed(column):
	var label = find_node("GroupingLabel")
	var desiredSortColumnName = BuglistTreeObj.get_column_title(column)
	#var enabled = ["Category", "Priority", "Date"]
#	if enabled.has(desiredSortColumnName):
	if ColDetails[desiredSortColumnName]["sortable"] == true:
		label.set_text(desiredSortColumnName)
		GroupBy = desiredSortColumnName
		populateTree(BuglistTreeObj, BugCollection, desiredSortColumnName)
		makeNoise(Noises.CLICK)
	else:
		makeNoise(Noises.ERROR)
		printerr("BugList.gd user trying to sort by inappropriate title.. maybe screenshake?")

func _on_tree_button_pressed(item, column, button_id):
	makeNoise(Noises.CLICK)

	var tooltip = item.get_button_tooltip(column, button_id)
	#print("pressed button: " + tooltip + " on item: " + item.get_text(Columns.find("title")))
	print("pressed button: " + tooltip + " on item: " + item.get_text(Columns.find("Title")))
	
	var bugId = int(item.get_text(Columns.find("Id")))
	var bug = getBug(bugId)
	
	if tooltip == "Delete":
		#print(bug.Title + " scheduled for deletion ")
		deleteBug(bug)
		item.free()
	elif tooltip == "Move to top":
		# not sure how to make this persistent
		item.move_to_top()
	elif tooltip == "Move to bottom":
		# not sure how to make this persistent. Need a DisplayOrderId
		item.move_to_bottom()
	elif tooltip == "Edit":
		var dialog = EditBugPopup
		dialog.popup_centered()
		populateBugDialog(dialog, bugId)


func _on_SaveButton_pressed():
	makeNoise(Noises.CLICK)
	var saveDialog = $Dialogs/SaveDialog
	saveDialog.set_current_file(DefaultSaveFilePath)
	$Dialogs/SaveDialog.popup_centered()

func _on_LoadButton_pressed():
	makeNoise(Noises.CLICK)
	$Dialogs/LoadDialog.popup_centered()


func _on_LoadDialog_file_selected(path):
	makeNoise(Noises.CLICK)
	JSONBugList = loadBugList(path)
	populateTree(BuglistTreeObj, generateBugCollection(JSONBugList), "category")
	


func _on_SaveDialog_file_selected(path):
	makeNoise(Noises.CLICK)
	saveBugList(path)


func _on_Tree_item_edited(): # only fires after user hits return or leaves the cell.
	var editedItem = BuglistTreeObj.get_edited()
	print("edited: " + str(editedItem))
	
	var bugId = int(editedItem.get_text(Columns.find("Id")))
	var bug = getBug(bugId)
	
	bug.Title = editedItem.get_text(Columns.find("Title"))
	bug.Details = editedItem.get_text(Columns.find("Details"))
#	print(bug.Title)
#	print(bug.Details)
	

	

	

func _on_NewBugButton_pressed():
	makeNoise(Noises.CLICK)
	print("New Bug Button Pressed")
	var dialog = EditBugPopup
	dialog.popup_centered()
	populateBugDialog(dialog, -1)
	


func _on_DiscardBugBtn_pressed():
	makeNoise(Noises.CLICK)

	# close the modal dialog box for creating a new bug or editing an existing bug
	EditBugPopup.hide()



func _on_SaveBugBtn_pressed(): # for a specific bug, from the new/edit bug dialog
	makeNoise(Noises.CLICK)

	saveBugFromDialog()
	
	



func _on_DeleteBugBtn_pressed():
	makeNoise(Noises.CLICK)

	# clear the bug edit form, erase the bug from bugcollection, repopulate the tree
	
	# get the bugID from the tree/form, then get the bug from the collection
	var tree = BugEditTreeNode
	var bugIDRow = treeTableFind(tree, 0, "Id")
	if bugIDRow != null:
		var bugID = bugIDRow.get_text(1)
		var bug = getBug(bugID)
		if bug != null: # new bugs won't exist in the Collection until they've been saved
			BugCollection.erase(bug)
		populateTree(BuglistTreeObj, BugCollection, GroupBy)
		tree.clear()
		EditBugPopup.hide()
	else:
		printerr("BugList.gd: problem in _on_DeleteBugBtn_pressed. No valid row for bugID")






func _on_ReturnButton_pressed():
	makeNoise(Noises.CLICK)
	yield(get_tree().create_timer(0.1), "timeout")
	emit_signal("finished", self)
	call_deferred("queue_free") # means you can never come back, until restart.
	
