extends Node
class_name PlayerCombat

var player: Player

@export var melee_cast: RayCast3D
@export var gun_cast: RayCast3D

@export var melee_range: float = 1.0
@export var gun_range: float = 1000.0

@export var weapons: Array[Weapon]
@export var wea_dmg: int = 10

@onready var weapon_holder: Node3D = %WeaponHolder

var cur_weapon: Weapon
var current_weapon_index: int = 0


func init(n_player: Player) -> void:
	player = n_player
	_setup_raycasts()
	_initialize_weapon_nodes()
	
	if weapons.size() > 0:
		equip_by_index(0)


func _initialize_weapon_nodes() -> void:
	# Hide all weapons initially and make sure signal isn't duplicated
	for w in weapons:
		if w:
			w.hide()


func equip_by_index(index: int) -> void:
	if index < 0 or index >= weapons.size():
		return
		
	current_weapon_index = index
	equip(weapons[index])


func equip(new_weapon: Weapon) -> void:
	if not new_weapon:
		push_warning("Equip failed: new_weapon is null.")
		return

	# Disconnect signal and hide previous weapon
	if is_instance_valid(cur_weapon):
		if cur_weapon.has_signal("raycast_toggled") and \
				cur_weapon.raycast_toggled.is_connected(check_raycast):
			cur_weapon.raycast_toggled.disconnect(check_raycast)
		cur_weapon.hide()

	# Show new weapon and set as active
	cur_weapon = new_weapon
	cur_weapon.init(player)
	cur_weapon.show()

	# Connect signal for the new active weapon
	if cur_weapon.has_signal("raycast_toggled"):
		cur_weapon.raycast_toggled.connect(check_raycast)


func equip_next() -> void:
	if weapons.is_empty():
		return

	var count = weapons.size()
	for i in range(1, count + 1):
		var check_index = (current_weapon_index + i) % count
		if weapons[check_index] != null:
			equip_by_index(check_index)
			return


func _setup_raycasts() -> void:
	if melee_cast:
		melee_cast.target_position = Vector3(0, 0, -melee_range)
		melee_cast.enabled = false
		
	if gun_cast:
		gun_cast.target_position = Vector3(0, 0, -gun_range)
		gun_cast.enabled = false


func shoot_cur_weapon() -> void:
	if cur_weapon:
		cur_weapon.fire()


func check_raycast() -> void:
	if not cur_weapon:
		return

	match cur_weapon.shoot_type:
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
	if cur_weapon and cur_weapon.has_method("spawn_projectile"):
		cur_weapon.spawn_projectile()


func _apply_damage(target: Object, _hit_point: Vector3, _hit_normal: Vector3) -> void:
	if not target:
		return

	# Safe check if target can take damage (handles HurtBox or custom nodes)
	if target.has_method("take_damage"):
		target.take_damage(wea_dmg)
	elif target is HurtBox:
		target.take_damage(wea_dmg)
