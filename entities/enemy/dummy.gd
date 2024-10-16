extends EnemyBase

@export var enemy_resource: Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var left_punch_attack = Attack.new()
var right_punch_attack = Attack.new()
var leg_sweep_attack = Attack.new()
var beam_attack = Attack.new()

func _ready() -> void:
	super()
	minium_beam_count = enemy_resource.minium_beam_count
	cur_approach_speed = enemy_resource.approach_speed
	
	create_attack_object(left_punch_attack, 5, ["RIGHT"],"left punch", 0)
	create_attack_object(right_punch_attack, 4, ["LEFT"],"right punch", 0)
	create_attack_object(leg_sweep_attack, 8, ["DOWN"],"leg sweep", 0)
	create_attack_object(beam_attack, 10, ["RIGHT", "LEFT", "UP", "DOWN", "CENTER"],"beam", 1)


func create_attack_object(new_attack: Attack, damage: int, stand: Array[String], anim: String, isBeam: bool):
	new_attack.atk_damage = damage
	new_attack.atk_stand = stand
	new_attack.atk_anim_name = anim
	if !isBeam:
		skill_array.append(new_attack)
	else:
		beam_array.append(new_attack)

func change_attack(new_attack: Attack):
	attack = new_attack
	

func handle_attack():
	pass


func on_attack_timer_timeout() -> void:
	walk_speed = 0
	approach_speed = -cur_approach_speed
	change_attack(get_skill())
	animation_player.play(attack.atk_anim_name)


func _on_animation_finished(anim_name: StringName) -> void:
	approach_speed = cur_approach_speed
	walk_speed = 1
	lock_movement = false
	attack_timer.start()
	attack_timer.wait_time = randf_range(1,4)
