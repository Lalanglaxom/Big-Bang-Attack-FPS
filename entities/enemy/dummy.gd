extends EnemyBase

@export var enemy_resource: Enemy

var left_punch_attack = Attack.new(5, ["RIGHT", "CENTER"], "left punch", 0)
var right_punch_attack = Attack.new(4, ["LEFT", "CENTER"], "right punch", 0)
var leg_sweep_attack = Attack.new(8, ["DOWN", "CENTER"], "leg sweep", 0)
var beam_attack = Attack.new(10, ["RIGHT", "LEFT", "UP", "DOWN", "CENTER"], "beam", 1)

func _ready() -> void:
	super()
	minium_beam_count = enemy_resource.minium_beam_count
	cur_approach_speed = enemy_resource.approach_speed
	
	add_attack_object(left_punch_attack)
	add_attack_object(right_punch_attack)
	add_attack_object(leg_sweep_attack)
	add_attack_object(beam_attack)

	create_parry_timing(left_punch_attack.atk_anim_name, 1, 0.2)
	create_parry_timing(right_punch_attack.atk_anim_name, 1, 0.2)
	create_parry_timing(leg_sweep_attack.atk_anim_name, 1, 0.2)
	create_parry_timing(beam_attack.atk_anim_name, 2, 0.2)


func on_attack_timer_timeout() -> void:
	walk_speed = 0
	approach_speed = -cur_approach_speed
	change_attack(get_skill())
	animation_player.play(attack.atk_anim_name)


func on_animation_finished(anim_name: StringName) -> void:
	approach_speed = cur_approach_speed
	walk_speed = 1
	lock_movement = false
	attack_timer.start()
	attack_timer.wait_time = randf_range(1,4)
