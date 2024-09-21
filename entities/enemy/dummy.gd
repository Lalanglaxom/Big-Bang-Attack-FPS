extends EnemyBase

@export var _skill = ["apple", "orange", "pear", "banana"]
@export var _beam = ["BEAM", "SUPER"]
@export var _minium_beam_count: int

var enemy_attack = EnemyAttack.new()

func _ready() -> void:
	super()
	enemy_attack.rng.randomize()
	enemy_attack.skill = _skill
	enemy_attack.beam = _beam
	enemy_attack.minium_beam_count = _minium_beam_count

func handle_attack():
	if Input.is_action_just_pressed("attack"):
		print(enemy_attack.use_skill())
