extends CharacterBody3D
class_name EnemyBase

const SPEED = 5.0
const JUMP_VELOCITY = 10

@onready var moving_timer: Timer = $MovingTimer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_chart: StateChart = $EnemyStateChart
@onready var player = get_tree().get_nodes_in_group("player")[0]

@export var enemy_resource: Enemy

var	time = 0
var walk_speed = 1
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()


func _physics_process(delta: float) -> void:
	look_at(player.global_position)
	update_wait_time(delta)

	handle_movement()
	move_and_slide()
	
	handle_attack()


func update_wait_time(delta):
	time += delta
	if time >= 5:
		moving_timer.wait_time = randf_range(3,6)
		time = 0


func handle_movement():
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * get_physics_process_delta_time()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	time += get_physics_process_delta_time()
	
	var direction := (transform.basis * Vector3(walk_speed, 0, 0))
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func damage(attack: Attack):
	return


func handle_attack():
	return


func _on_distance_timer_timeout() -> void:
	walk_speed *= -1


func handle_state():
	return


func switch_state(state_name: String):
	state_chart.send_event(state_name)


class EnemyAttack:
	var skill = ["apple", "orange", "pear", "banana"]
	var beam = ["beam", "slash"]
	var minium_beam_count = 4

	var last_skill = ""
	var last_skill_count = 0
	var total_skill_count = 0
	var skill_need_to_beam = 6
	var rng = RandomNumberGenerator.new()
		
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
