extends Node2D

# Declare member variables here. Examples:
export var BulletScene : PackedScene
export var BulletSpeed : float = 1500

var MyShip : Area2D
var TimesFired : int = 0
var DefaultReloadTime : float = 0.33
var DefaultSwapMagazineTime : float = 2.0
var NumShotsInBurst : int = 3
var MagazineSize = NumShotsInBurst
onready var ReloadTimer = $ReloadTimer
onready var SwapMagazineTimer = $SwapMagazineTimer

export var ShipToShip : bool = true
export var ShipToGround : bool = false

enum Status {READY, FIRING, RELOADING, SWAPPING_MAGAZINE}
var WeaponStatus = Status.READY

signal weapons_ready()

# Called when the node enters the scene tree for the first time.
func _ready():
	MyShip = get_parent().get_parent() # all weapons are in a Weapons container
	DefaultReloadTime = ReloadTimer.get_wait_time()
	DefaultSwapMagazineTime = SwapMagazineTimer.get_wait_time()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawnLaser(pos):
	var rot = get_global_rotation()
	var rotDeviation = rand_range(-PI/16, PI/16)
	var vel = Vector2(1,0).rotated(rot) * BulletSpeed
	var newBullet = BulletScene.instance()
	MyShip.Level.BulletContainer.add_child(newBullet)
	newBullet.start(pos, rot + rotDeviation, vel, MyShip.FactionObj)

func fire():
	TimesFired += 1
	for muzzle in $Muzzles.get_children():
		spawnLaser(muzzle.get_global_position())


# fire bursts of 12 shots every time something enters firing arc
func CommenceFiring():
	TimesFired = 0
	ReloadTimer.set_wait_time(DefaultReloadTime / max(global.game_speed, 0.0001))
	ReloadTimer.start()
	WeaponStatus = Status.FIRING
	

###############################################################################
# Outgoing Signals

func notifyShipWeaponsReady():
	connect("weapons_ready", MyShip, "_on_weapons_reported_ready")
	emit_signal("weapons_ready")
	disconnect("weapons_ready", MyShip, "_on_weapons_reported_ready")

###############################################################################
# Incoming Signals

func _on_ReloadTimer_timeout():
	if MyShip.State != MyShip.States.DEAD:
		if TimesFired <= MagazineSize:
			fire()
			# this might cause issues coming back from pause..
			ReloadTimer.set_wait_time(DefaultReloadTime / max(global.game_speed, 0.0001) )
			ReloadTimer.start()
		elif TimesFired > MagazineSize:
			WeaponStatus = Status.SWAPPING_MAGAZINE
			if global.game_speed > 0.0:
				SwapMagazineTimer.set_wait_time(DefaultSwapMagazineTime / max(global.game_speed, 0.0001))
				SwapMagazineTimer.start()
			else:
				printerr("Weapons.gd needs a pause function in _on_ReloadTimer_timeout")
			

	

# the SwapMagazineTimer sends a signal to the Weapons and to the Ship itself.
func _on_SwapMagazineTimer_timeout():
	WeaponStatus = Status.READY
	notifyShipWeaponsReady()
	
	
