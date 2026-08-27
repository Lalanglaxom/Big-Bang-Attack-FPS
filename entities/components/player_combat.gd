extends Node
class_name PLayerCombat

var player: Player

@export var melee_cast: RayCast3D
@export var gun_cast: RayCast3D

@export var melee_range: float = 1.0
@export var gun_range: float = 1000.0

@export var weapon: Weapon
@export var wea_dmg: int = 10

func init(n_player: Player) -> void:
	player = n_player
	
	if melee_cast:
		melee_cast.target_position = Vector3(0, 0, -melee_range)
		melee_cast.enabled = false
		
	if gun_cast:
		gun_cast.target_position = Vector3(0, 0, -gun_range)
		gun_cast.enabled = false
		
	if weapon and weapon.has_signal("raycast_toggled"):
		weapon.raycast_toggled.connect(check_raycast)


func shoot_weapon() -> void:
	if weapon:
		weapon.fire()


func check_raycast() -> void:
	if not weapon:
		return

	match weapon.shoot_type:
		Weapon.ShootType.HITSCAN:
			_perform_hitscan()
		Weapon.ShootType.MELEE:
			_perform_melee()
		Weapon.ShootType.PROJECTILE:
			_perform_projectile()


func _perform_hitscan() -> void:
	if not gun_cast:
		return
		
	gun_cast.force_raycast_update()
	
	if gun_cast.is_colliding():
		var hit_collider = gun_cast.get_collider()
		var hit_point = gun_cast.get_collision_point()
		var hit_normal = gun_cast.get_collision_normal()
		
		_apply_damage(hit_collider, hit_point, hit_normal)


func _perform_melee() -> void:
	if not melee_cast:
		return
		
	melee_cast.force_raycast_update()
	
	if melee_cast.is_colliding():
		var hit_collider = melee_cast.get_collider()
		var hit_point = melee_cast.get_collision_point()
		var hit_normal = melee_cast.get_collision_normal()
		
		_apply_damage(hit_collider, hit_point, hit_normal)


func _perform_projectile() -> void:
	# Instantiate projectile scene here if using physical bullets
	pass


func _apply_damage(target: HurtBox, _hit_point: Vector3, _hit_normal: Vector3) -> void:
	target.take_damage(wea_dmg)
