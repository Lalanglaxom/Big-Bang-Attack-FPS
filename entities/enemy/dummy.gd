extends EnemyBase

@export var _skill = ["left punch"]
@export var _beam = ["beam"]
#, "right punch", "leg sweep"
@export var _minium_beam_count: int
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var left_punch_attack = Attack.new()
var right_punch_attack = Attack.new()
var leg_sweep_attack = Attack.new()
var beam_attack = Attack.new()

func _ready() -> void:
	super()
	skill = _skill
	beam = _beam
	minium_beam_count = _minium_beam_count
	cur_approach_speed = 4
	
	create_attack_object(left_punch_attack, 5, [1])
	create_attack_object(right_punch_attack, 4, [0])
	create_attack_object(leg_sweep_attack, 8, [3])
	create_attack_object(beam_attack, 10, [0,1,2,3,4])
	attack = left_punch_attack
	
func create_attack_object(attack: Attack, damage: int, stand: Array[int]):
	attack.atk_damage = damage
	for i in stand:
		attack.atk_stand.append(i)

func change_attack(new_attack: Attack):
	attack.atk_damage = new_attack.atk_damage
	attack.atk_stand = new_attack.atk_stand


func handle_attack():
	if Input.is_action_just_pressed("attack"):
		walk_speed = 0
		approach_speed = -cur_approach_speed
		animation_player.play(use_skill())


func _on_animation_finished(anim_name: StringName) -> void:
	approach_speed = cur_approach_speed
	walk_speed = 1
	lock_movement = false
