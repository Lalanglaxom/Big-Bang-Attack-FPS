extends CharacterBody3D
class_name EnemyBase

const SPEED = 5.0
const JUMP_VELOCITY = 10

@onready var moving_timer: Timer = $MovingTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_chart: StateChart = $EnemyStateChart
@onready var player = get_tree().get_nodes_in_group("player")[0]

@export var hello: int

var	time = 0
var walk_speed = 1
var approach_speed = 0
var cur_approach_speed: float
var rng = RandomNumberGenerator.new()
var base_distance: float
var lock_movement = false


## Attack
var skill_array: Array[Attack]
var skill_anim = []
var beam_array: Array[Attack]
var beam_anim = []
var minium_beam_count = 4

var last_skill: Attack
var last_skill_count = 0
var total_skill_count = 0
var skill_need_to_beam = 6

var attack = Attack.new()

func _ready() -> void:
	rng.randomize()
	moving_timer.timeout.connect(on_distance_timer_timeout)
	attack_timer.timeout.connect(on_attack_timer_timeout)
	base_distance = position.distance_to(player.position)

func _physics_process(delta: float) -> void:
	look_at(player.global_position)
	rotation.x = 0
	rotation.z = 0
	
	update_wait_time(delta)

	handle_movement()
	handle_attack()




func handle_movement():
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * get_physics_process_delta_time()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	time += get_physics_process_delta_time()
	
	var direction := (transform.basis * Vector3(walk_speed, 0, approach_speed))
	
	if lock_movement:
		direction = Vector3.ZERO
		
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if position.distance_to(player.position) < 4:
		if approach_speed < 0:
			lock_movement = true
			
	if position.distance_to(player.position) >= base_distance:
		if approach_speed > 0:
			approach_speed = 0
		
	move_and_slide()

func get_skill() -> Attack:
	if skill_array.size() == 1:
		return skill_array[0]
	
	var random_skill = skill_array[randi() % skill_array.size()]
	# skill only repeat once
	while last_skill_count == 1:
		random_skill = skill_array[randi() % skill_array.size()]
		if random_skill != last_skill:
			last_skill_count = 0
				
	if random_skill == last_skill:
		last_skill_count = 1

	last_skill = random_skill
		
	if total_skill_count >= skill_need_to_beam:
		random_skill = beam_array[randi() % beam_array.size()]
		skill_need_to_beam = rng.randi_range(minium_beam_count, minium_beam_count + 3)
		total_skill_count = 0
	else:
		total_skill_count += 1
		
	return random_skill


func damage(attack: Attack):
	player.take_damage(attack)


func call_damage():
	damage(attack)

func take_damage(attack: Attack):
	pass


func handle_attack():
	pass


func update_wait_time(delta):
	time += delta
	if time >= 5:
		moving_timer.wait_time = randf_range(2,5)
		time = 0
		
		
func on_distance_timer_timeout() -> void:
	walk_speed *= -1


func on_attack_timer_timeout() -> void:
	print("Attack")


func handle_state():
	return


func switch_state(state_name: String):
	state_chart.send_event(state_name)
