extends Node3D
class_name Weapon

signal raycast_toggled

enum ShootType { HITSCAN, MELEE, PROJECTILE }

@export var shoot_type: ShootType = ShootType.HITSCAN
@export var shoot_anim_name: StringName = &"shoot"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player: Player

func init(n_player: Player) -> void:
	player = n_player


func fire() -> void:
	match shoot_type:
		ShootType.HITSCAN:
			_handle_hitscan_fire()
			trigger_raycast()
		ShootType.MELEE:
			_handle_melee_fire()
		ShootType.PROJECTILE:
			_handle_projectile_fire()
			
	play_shoot_anim()


func play_shoot_anim() -> void:
	if animation_player and animation_player.has_animation(shoot_anim_name):
		animation_player.seek(0.0, true)
		animation_player.play(shoot_anim_name)


func trigger_raycast() -> void:
	raycast_toggled.emit()


func _handle_hitscan_fire() -> void:
	pass


func _handle_melee_fire() -> void:
	pass


func _handle_projectile_fire() -> void:
	pass
