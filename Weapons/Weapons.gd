extends Node2D

# Declare member variables here. Examples:
export var BulletScene : PackedScene
export var BulletSpeed : float = 1500

var TimesFired : int = 0
var MyShip : Area2D
var NumShotsInBurst : int = 3
var MagazineSize = NumShotsInBurst

enum Status {READY, FIRING, RELOADING}
var WeaponStatus = Status.READY

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
	WeaponStatus = Status.FIRING
	

func _on_ReloadTimer_timeout():
	if MyShip.State != MyShip.States.DEAD:
		if TimesFired <= MagazineSize:
			fire()
			get_node("ReloadTimer").start()
		elif TimesFired > MagazineSize:
			WeaponStatus = Status.RELOADING
			
			get_node("SwapMagazineTimer").start()
			

	

# the SwapMagazineTimer sends a signal to the Weapons and to the Ship itself.
func _on_SwapMagazineTimer_timeout():
	WeaponStatus = Status.READY
	
	
