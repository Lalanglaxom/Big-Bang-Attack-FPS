extends Node3D

@onready var character = $Character
@onready var enemy = preload("res://entities/enemy/saihaimen.tscn")
@onready var enemy_spawn = $EnemySpawn
@onready var ui = $UI

var amount = 3
var win_amount = 10
var rng = RandomNumberGenerator.new()
var spawn


func _ready():
	Global.on_enemy_die.connect(enemy_manager)
	spawn = enemy_spawn.global_position
	Global.enemy_remain = 3
	
	for i in range(amount):
		spawn_enemy()
	
	Global.ui = ui
	ui.hide()
	Global.on_pause.connect(ui_controller)
	
	
func _physics_process(delta):
	get_tree().call_group("enemies","update_target",character)
	print(Global.endless)

func enemy_manager():
	Global.enemy_remain -= 1
	if Global.enemy_remain == 0:
		if amount == win_amount and Global.endless == false:
			await get_tree().create_timer(2).timeout
			get_tree().change_scene_to_file("res://scenes/win.tscn")
		else:
			amount += 1
			await get_tree().create_timer(3).timeout
			Global.enemy_remain = amount
			for i in range(amount):
				spawn_enemy()
			
		


func ui_controller():
	if get_tree().paused == false:
		ui.show()
		get_tree().paused = true
	else:
		ui.hide()
		get_tree().paused = false
	
func spawn_enemy():
	rng.randomize()
	var instance = enemy.instantiate()
	instance.position = Vector3(randf_range(-36,32), spawn.y,randf_range(-31,25))
	get_tree().get_root().get_child(0).add_child(instance)

	
func _on_character_health_depleted():
	get_tree().change_scene_to_file("res://scenes/death.tscn")


func _on_menu_button_up():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	

func _on_quit_button_up():
	get_tree().quit()
