extends Node2D

# Declare member variables here. Examples:
export var BulletScene : PackedScene
export var BulletSpeed : float = 500

var TimesFired : int = 0
var MyShip : Area2D
var NumShotsInBurst : int = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	MyShip = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawnLaser(pos):
	var rot = get_global_rotation()
	var rotDeviation = rand_range(-PI/16, PI/16)
	var vel = Vector2(1,0).rotated(rot) * BulletSpeed
	var newBullet = BulletScene.instance()
	global.BulletContainer.add_child(newBullet)
	newBullet.start(pos, rot + rotDeviation, vel, MyShip.Faction)

func fire():
	TimesFired += 1
	for muzzle in $Muzzles.get_children():
		spawnLaser(muzzle.get_global_position())


# fire bursts of 12 shots every time something enters firing arc
func CommenceFiring():
	TimesFired = 0
	$ReloadTimer.start()
	

func _on_ReloadTimer_timeout():
	if TimesFired < NumShotsInBurst and MyShip.State != MyShip.States.DEAD:
		fire()
		$ReloadTimer.start()

	
