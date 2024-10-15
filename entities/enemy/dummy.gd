extends EnemyBase

@export var _skill = ["left punch", "right punch", "leg sweep"]
@export var _beam = ["beam"]
@export var _minium_beam_count: int

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var enemy_attack = EnemyAttack.new()

func _ready() -> void:
	super()
	skill = _skill
	beam = _beam
	minium_beam_count = _minium_beam_count
	cur_approach_speed = 4

func handle_attack():
	if Input.is_action_just_pressed("attack"):
		walk_speed = 0
		approach_speed = -cur_approach_speed
		animation_player.play(use_skill())

func use_skill():
	var random_skill = skill[randi() % skill.size()]
	# skill only repeat once
	while last_skill_count == 1:
		random_skill = skill[randi() % skill.size()]
		if random_skill != last_skill:
			last_skill_count = 0
				
	if random_skill == last_skill:
		last_skill_count = 1

	last_skill = random_skill
		
	if total_skill_count >= skill_need_to_beam:
		random_skill = beam[randi() % beam.size()]
		skill_need_to_beam = rng.randi_range(minium_beam_count, minium_beam_count + 3)
		total_skill_count = 0
	else:
		total_skill_count += 1
	return random_skill

func _on_animation_finished(anim_name: StringName) -> void:
	approach_speed = cur_approach_speed
	walk_speed = 1
	lock_movement = false
