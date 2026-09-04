extends Node3D
class_name Weapon

signal raycast_toggled

enum ShootType { HITSCAN, MELEE, PROJECTILE }

@export var shoot_type: ShootType = ShootType.HITSCAN
@export var shoot_anim_name: StringName = &"shoot"
@export var projectile: PackedScene

@export_category("Stats")
@export var fire_rate: float = 0.5  # Time in seconds between shots (e.g. 0.5s = 2 shots/sec)

@onready var muzzle: Node3D = $Muzzle
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var player: Player
var fire_cooldown: float = 0.0  # Tracks remaining cooldown time


func init(n_player: Player) -> void:
	player = n_player


func _process(delta: float) -> void:
	# Continuously decrement cooldown until it hits 0
	if fire_cooldown > 0.0:
		fire_cooldown -= delta


func fire() -> void:
	# 1. Check if weapon is ready to fire
	if fire_cooldown > 0.0:
		return

	# 2. Reset cooldown timer to fire_rate interval
	fire_cooldown = fire_rate

	# 3. Fire logic
	match shoot_type:
		ShootType.HITSCAN:
			_handle_hitscan_fire()
		ShootType.MELEE:
			_handle_melee_fire()
		ShootType.PROJECTILE:
			_handle_projectile_fire()
			
	play_shoot_anim()


func play_shoot_anim() -> void:
	if anim_player and anim_player.has_animation(shoot_anim_name):
		anim_player.seek(0.0, true)
		anim_player.play(shoot_anim_name)


func trigger_raycast() -> void:
	raycast_toggled.emit()


func _handle_hitscan_fire() -> void:
	pass


func _handle_melee_fire() -> void:
	pass


func _handle_projectile_fire() -> void:
	if not projectile:
		push_warning("No projectile scene assigned to weapon!")
		return

	var proj = projectile.instantiate() as Projectile
	get_tree().current_scene.add_child(proj)
	
	# Get camera pitch angle
	var cam_euler = player.camera.global_basis.get_euler()
	var pitch = cam_euler.x
	
	var spawn_pos: Vector3 = player.camera.global_position
	
	# Check if looking almost straight down
	if pitch < -1.565:
		proj.global_basis = Basis.looking_at(Vector3.DOWN, Vector3.FORWARD)
	
	if pitch > 1.565:
		proj.global_basis = Basis.looking_at(Vector3.UP, Vector3.FORWARD)
		
	# Normal camera aim setup
	proj.setup_target(spawn_pos, muzzle.global_position)
