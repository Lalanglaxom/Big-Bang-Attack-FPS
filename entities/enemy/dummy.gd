extends EnemyBase

@export var _skill = ["left punch", "right punch", "leg sweep"]
@export var _beam = ["beam"]
@export var _minium_beam_count: int

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var enemy_attack = EnemyAttack.new()

func _ready() -> void:
	super()
	enemy_attack.rng.randomize()
	enemy_attack.skill = _skill
	enemy_attack.beam = _beam
	enemy_attack.minium_beam_count = _minium_beam_count


func handle_attack():
	if Input.is_action_just_pressed("attack"):
		walk_speed = 0
		approach_speed = -3
		animation_player.play(enemy_attack.use_skill())


func _on_animation_finished(anim_name: StringName) -> void:
	approach_speed = 3
	walk_speed = 1
	lock_movement = false
