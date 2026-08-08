extends Node3D

@export var animation_tree: AnimationTree
@export var current_weapon: Weapon:
	set(value):
		current_weapon = value
		if Engine.is_editor_hint():
			exit()	
			enter()
			
			
@export var weapon_loadout: Array[Weapon]

@onready var view_model_cam = $"../.."
@onready var aim_end = $"../Aim_End"

var cur_weapon_scene
var ammo: Ammo

var weapon_index = 0
var delay_time = 0

func _ready():
	initialize()

func _process(delta):
	if not Engine.is_editor_hint():
		_weapon_switch()
		
	delay_time -= delta
	
func initialize():
	current_weapon = weapon_loadout[weapon_index]
	enter()

func enter() -> void:
	# Instantiate weapon
	cur_weapon_scene = current_weapon.weapon_scene.instantiate()
	add_child(cur_weapon_scene)
	#cur_weapon_scene.set_owner(get_tree().get_edited_scene_root())

	# Set position,rotation,scale
	position = current_weapon.position
	rotation_degrees = current_weapon.rotation
	scale = current_weapon.scale

	# Set animation 
	var wea_anim_path = cur_weapon_scene.get_node("AnimationPlayer").get_path()
	animation_tree.set_animation_player(wea_anim_path)

	# Load Ammo
	ammo = current_weapon.weapon_ammo
	
func exit():
	cur_weapon_scene.queue_free()

func _weapon_switch():
	if Input.is_action_just_pressed("weapon_up"):
		
		# ((a % b) + b) % b Modulo
		weapon_index = ((((weapon_index + 1) % weapon_loadout.size()) 
		+ weapon_loadout.size()) % weapon_loadout.size())
		
		current_weapon = weapon_loadout[weapon_index]
		exit()	
		enter()
		
	
	if Input.is_action_just_pressed("weapon_down"):
		
		# ((a % b) + b) % b Modulo
		weapon_index = ((((weapon_index - 1) % weapon_loadout.size()) 
		+ weapon_loadout.size()) % weapon_loadout.size())
		
		current_weapon = weapon_loadout[weapon_index]
		exit()	
		enter()
		
	
func _shoot() -> void:
	var ammo_scene = ammo.ammo_scene.instantiate()
	var weapon_projectile = cur_weapon_scene.get_node("ProjectilePos")
	ammo_scene.position = weapon_projectile.global_position
	ammo_scene.rotation = aim_end.global_rotation
	Global.projectile_path = _projectile_path()
	get_tree().root.get_child(0).add_child(ammo_scene)
	delay_time = current_weapon.delay_time

func _projectile_path():
	var weapon_projectile = cur_weapon_scene.get_node("ProjectilePos")
	return aim_end.global_position - weapon_projectile.global_position


func _on_character_shoot_button_clicked():
	if delay_time <= 0:
		_shoot()
	else:
		pass
