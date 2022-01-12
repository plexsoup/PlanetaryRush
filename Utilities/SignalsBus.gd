extends Node

# a place where we can coordinate signals between nodes.
# follow the Observer pattern.
# https://www.gdquest.com/docs/guidelines/best-practices/godot-gdscript/event-bus/

# Requirements and Dependencies
# requires a separate sdEvent class with name, memberlist, etc.



# Declare member variables here. Examples:
var BroadcastEvents : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func registerEvent(eventName, eventObj):
	# nodes can set up their event for public broadcast
	if BroadcastEvents.has("eventName"):
		printerr("eventName already registered in SignalsBus.gd")
	else:
		BroadcastEvents[eventName] = eventObj

func subscribeToEvent(interestedNode, eventName):
	# for nodes wanting to receive signals for an event 
	if BroadcastEvents.has(eventName):
		BroadcastEvents[eventName].registerRecipient(interestedNode)
		
func unsubscribeFromEvent(uninterestedNode, eventName):
	if BroadcastEvents.has(eventName):
		BroadcastEvents[eventName].unsubscribe(uninterestedNode)

func broadcastEvent(eventName, parametersArr):
	if BroadcastEvents.has(eventName):
		BroadcastEvents[eventName].broadcast()

func QuickSignal(requestingObj, signalName, targetObject, targetFunction, parameters : Array = []):
	# sometimes useful when you just want a quick signal.
	# takes parameters as an array to get around the variable parameter count.

	# connects a signal, emits the signal, disconnects the signal

	# note: this is an anti-pattern. Use at own risk.
	# if you always knew the exact object to signal, you might as well just call a function directly.
	# signals are best used when you don't know who you're talking to.
	# that way, the game dev can wire up signals manually depending on different situations

	# eg: when a timer completes, the recipient of the signal isn't hard-wired, it's connected.
	
	if is_instance_valid(targetObject) and targetObject.has_method(targetFunction):
		#requestingObj.connect( signalName, targetObject, targetFunction)
		var argsArray = [signalName, targetObject, targetFunction]
		if parameters.size() > 0:
			argsArray.append_array(parameters)
		requestingObj.callv("connect", argsArray)
		requestingObj.emit_signal(signalName)
		requestingObj.callv("disconnect", argsArray)
	else:
		printerr("SignalsBus.gd : invalid targetObject or targetFunction")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
