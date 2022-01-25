
extends Node

export var CheckMarkButtonTex : StreamTexture
export var DeleteIconTex : StreamTexture
export var DownArrowTex : StreamTexture
export var UpArrowTex : StreamTexture

var DetailTextBox
var BuglistTreeObj : Tree

var BugCollection : Array = [] # resource objects to manipulate bugs

var JSONBugList

#var Columns = ["id", "title", "details", "actions"]
#var ColDetails = {
#	"id":{"width":75, "expand":false, "editable":false},
#	"title":{"width":225, "expand":false, "editable":true},
#	"details":{"width":425, "expand":true, "editable":true},
#	"actions":{"width":250, "expand":false, "editable":false},
#}

var Columns = ["category", "id", "title", "details", "priority", "dependencies", "date", "actions"]
var ColDetails = {
	"category":{"width":75, "expand":false, "editable":false},
	"id":{"width":25, "expand":false, "editable":false},
	"title":{"width":150, "expand":false, "editable":true},
	"details":{"width":200, "expand":true, "editable":true},
	"priority":{"width":75, "expand":false, "editable":true},
	"dependencies":{"width":25, "expand":false, "editable":false},
	"date":{"width":55, "expand":false, "editable":false},
	"actions":{"width":85, "expand":false, "editable":false},
}

signal finished

func _ready():
	if get_tree().get_root().get_children().has(self): # running scene solo
		call_deferred("start", [null])
	else: # running scene in the game
		pass
		# The main menu will call start when the user requests it

func start(callbackObj):
	setPanelSize()
	
	
	var jsonBugList = loadBugList("user://saved_buglist.dat")
	var buglist = generateBugCollection(jsonBugList)
	var tree = createTree()
	populateTree(tree, buglist)
	BugCollection = buglist

func setPanelSize():
	var viewportSize = get_viewport().get_size()
	self.rect_size = viewportSize

func populateTree(treeNode, collectionOfBugs):
	var rootItem = treeNode.get_root()
	var categories = []
	for bug in collectionOfBugs:
		if not categories.has(bug.Category):
			categories.push_back(bug.Category)
	
	for category in categories:
		var categoryItem = treeNode.create_item(rootItem)
		categoryItem.set_text(0, category)
	
		for bug in collectionOfBugs:
			if bug.Category == category:
				var bugItem = treeNode.create_item(categoryItem)
				bugItem.set_text(1, str(bug.ID))
				bugItem.set_text(2, bug.Title)
				bugItem.set_editable(2, true)
				bugItem.set_text(3, bug.Details)
				bugItem.set_editable(3, true)
				bugItem.set_text(4, bug.Priority)
				bugItem.set_editable(2, true)
				bugItem.set_text(5, str(bug.Dependencies))
				bugItem.set_text(6, str(bug.DateCreated))
				bugItem.add_button(7, DeleteIconTex )
				bugItem.add_button(7, DownArrowTex)
				bugItem.add_button(7, UpArrowTex)
		
	
func scaleButtons(tree, column, scale):
	
	var root = tree.get_root()
	
	
	
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

	marginBox.add_child(tree)
	BuglistTreeObj = tree
	var root = tree.create_item()
	tree.set_hide_root(false)
	



	return tree

	
#	for buglistSubDict in buglistDictionary:
#		old_populate_branch(tree, tree.get_root(), buglistSubDict, buglistDictionary[buglistSubDict])
#


	
func old_populate_branch(treeObj, currentTreeItemNode, branchName, branchContents):
	
	var newBranchNode = treeObj.create_item(currentTreeItemNode)
	newBranchNode.set_text(0, branchName)
	#print(branchContents)
	var i = 0
	for key in branchContents.keys():
		var itemObj = treeObj.create_item(newBranchNode)
		itemObj.set_text(0, str(i))
		itemObj.set_text(1, key)
		itemObj.set_text(2, branchContents[key])
		itemObj.add_button(3, CheckMarkButtonTex )
		itemObj.add_button(3, DownArrowTex)
		itemObj.add_button(3, UpArrowTex)
		
		for colNum in Columns.size():
			itemObj.set_editable(colNum, ColDetails[Columns[colNum]]["editable"])
		
		i += 1


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
	
	
	
func convertTableToGroups(groupColumn : int, table : Dictionary):
	# make a nested json, grouped by a given column in a flat table
	printerr("DesignNotes.gd: convertTableToGroups needs development")

func updateJSONFromTable():
	printerr("DesignNotes.gd: updateJSONFromTable needs development")
	var newDict = {}
	for item in BuglistTreeObj.get_items():
		pass
	

func jsonifyBuglist() -> String :
	var blDict = {}
	var jsonBuglist = ""
	var cols = ["category", "id", "title", "details", "priority", "dependencies", "date"]
	for bug in BugCollection:
		blDict[bug.ID] = {
			"category" : bug.Category,
			"id" : bug.ID,
			"title" : bug.Title,
			"details" : bug.Details,
			"priority" : bug.Priority,
			"dependencies" : bug.Dependencies,
			"date" : bug.DateCreated,
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
	var bugResource = preload("res://DesignDocs/bug_resource.tres")
	# if the dictionary is multi-level?
	if isDictNested(tempBuglist):
		var i : int = 0
		for categoryName in tempBuglist.keys():
			#print(categoryName)
			for bugDict in tempBuglist[categoryName]:
				#print(bugDict)
				var bug = bugResource.duplicate() # resources are weird. They don't have new or instance functions.
				bug.Category = categoryName
				bug.ID = i # we'll want to change this once we have a flat table
				#print(tempBuglist[categoryName])
				bug.Title = bugDict
				bug.Details = tempBuglist[categoryName][bugDict]
				bug.Priority = "medium"
				bug.Dependencies = []
				bug.DateCreated = OS.get_unix_time()
				bugCollection.push_back(bug)
				i += 1
	else: # not nested. We've already converted it into a flattened table
		var i : int = 0
		for bugItem in tempBuglist.values():
			var bug = bugResource.duplicate()
			bug.Category = bugItem["category"]
			bug.ID = bugItem["id"] # we'll want to change this once we have a flat table
			
			
			bug.Title = bugItem["title"]
			
			bug.Details = bugItem["details"]
			bug.Priority = bugItem["priority"]
			bug.Dependencies = bugItem["dependencies"]
			bug.DateCreated = bugItem["date"]
			bugCollection.push_back(bug)
			i += 1
	#prettyPrintBugs(bugCollection)
	return bugCollection

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
	

func _on_tree_button_pressed(item, column, button_id):
	
	print("pressed button: " + str(item.get_text(0)))



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

func _on_SaveButton_pressed():
	$SaveDialog.popup_centered()

func _on_LoadButton_pressed():
	$LoadDialog.popup_centered()


func _on_LoadDialog_file_selected(path):
	JSONBugList = loadBugList(path)
	BuglistTreeObj.clear()
	populateTree(BuglistTreeObj, generateBugCollection(JSONBugList))
	


func _on_SaveDialog_file_selected(path):
	saveBugList(path)


func _on_Tree_item_edited(): # only fires after user hits return or leaves the cell.
	var editedItem = BuglistTreeObj.get_edited()
	print("edited: " + str(editedItem))
	
	var bugID = int(editedItem.get_text(Columns.find("id")))
	var bug = getBug(bugID)
	
	bug.Title = editedItem.get_text(Columns.find("title"))
	bug.Details = editedItem.get_text(Columns.find("details"))
#	print(bug.Title)
#	print(bug.Details)
	
