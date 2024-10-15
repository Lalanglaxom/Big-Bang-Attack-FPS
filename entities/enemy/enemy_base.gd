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
var approach_speed = 0
var cur_approach_speed: float
var rng = RandomNumberGenerator.new()
var base_distance: float
var lock_movement = false


## Attack
var skill = ["apple", "orange", "pear", "banana"]
var beam = ["beam", "slash"]
var minium_beam_count = 4

var last_skill = ""
var last_skill_count = 0
var total_skill_count = 0
var skill_need_to_beam = 6

func _ready() -> void:
	rng.randomize()
	base_distance = position.distance_to(player.position)

func _physics_process(delta: float) -> void:
	look_at(player.global_position)
	rotation.x = 0
	rotation.z = 0
	
	update_wait_time(delta)

	handle_movement()
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
	
func damage(attack: Attack):
	return


func handle_attack():
	pass


func _on_distance_timer_timeout() -> void:
	walk_speed *= -1


func handle_state():
	return


func switch_state(state_name: String):
	state_chart.send_event(state_name)


class EnemyAttack:
	var atk_stand = []
	var atk_damage: int
