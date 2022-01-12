extends Node2D

# Declare member variables here. Examples:
enum States { INITIALIZING, MOVING, EXPLODING } 
var State = States.MOVING
var Velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(pos, rot, vel, factionObj):
	set_global_position(pos)
	set_global_rotation(rot)
	Velocity = vel
	if is_instance_valid(factionObj): # neutral planets don't have a faction
		$projectile.set_self_modulate(factionObj.fColor)
	shoot()
	
func shoot():
	$DelayTimer.set_wait_time(rand_range(0.6, 1.5))
	$DelayTimer.start()
	State = States.MOVING

func explode():
	var explosionSprite = get_node("Explosion")
	var randScale = rand_range(1.0, 10.0)
	explosionSprite.scale.x = randScale
	explosionSprite.scale.y = randScale
	var randColors = PoolColorArray([Color.coral, Color.darkorange, Color.gold, Color.red, Color.azure, Color.deeppink])
	var randColor = randColors[randi()%randColors.size()]
	explosionSprite.set_self_modulate(randColor)
	
	State = States.EXPLODING
	$AnimationPlayer.play("explode")
	yield($AnimationPlayer, "animation_finished")
	call_deferred("queue_free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.MOVING:
		var myPos = get_global_position()
		set_global_position(myPos + (Velocity * delta))


func _on_DelayTimer_timeout():
	explode()

