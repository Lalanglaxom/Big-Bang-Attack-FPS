extends Node
class_name MovementComponent

var crouched: bool = false
var crouch_blocked: bool = false

enum {GROUND_CROUCH = -1, STANDING = 0, AIR_CROUCH = 1}

@export_category("Crouch Parametres")
@export var enable_crouch: bool = true
@export var crouch_collider: ShapeCast3D
@export_range(0.0,3.0) var crouch_speed_reduction = 2.0
@export_range(0.0,0.50) var crouch_blend_speed = .2


@export_category("Speed Parameters")
@export var enable_sprint: bool = true
@export var sprint_timer: Timer
@export var sprint_cooldown_time: float = 3.0
@export var sprint_time: float = 1.0
@export var sprint_replenish_rate: float = 0.30
@export var acceleration: float = 120
@export_range(0.01,1.0) var air_acceleration_modifier: float = 0.1
var sprint_on_cooldown: bool = false
var sprint_time_remaining: float = sprint_time
@export var sprint_bar: Range

const NORMAL_speed = 1
@export_range(1.0,3.0) var sprint_speed: float = 2.0
@export_range(0.1,1.0) var walk_speed: float = 0.5
var speed_modifier: float = NORMAL_speed

@export_category("Jump Parameters")
@export var coyote_timer: Timer
@export var jump_peak_time: float = .5
@export var jump_fall_time: float = .5
@export_range(.4,4,.2) var jump_height: float = 2.0
@export_range(.4,4,.2) var jump_distance: float = 4.0
@export var coyote_time: float = .1
@export var jump_buffer_time: float = .2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var jump_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall_gravity: float
var jump_velocity: float
var base_speed: float 
var _speed: float 
var jump_available: bool = true
var jump_buffer: bool = false

@export var player: Player

func init(new_player: Player) -> void:
	player = new_player
	calculate_movement_parameters()

func _unhandled_input(event: InputEvent) -> void:
	if enable_crouch:
		if event.is_action_pressed("crouch"):
			crouch()
		if event.is_action_released("crouch"):
			if crouched:
				crouch()
		
	if enable_sprint:
		if Input.is_action_just_pressed("sprint") and !crouched:
			if !sprint_on_cooldown:
				speed_modifier = sprint_speed
				sprint_timer.start(sprint_time_remaining)
				
		if Input.is_action_just_released("sprint") or Input.is_action_just_released("walk"):
			if !(Input.is_action_pressed("walk") or Input.is_action_pressed("sprint")):
				speed_modifier = NORMAL_speed
				exit_sprint()
				
		if Input.is_action_just_pressed("walk") and !crouched:
			speed_modifier = walk_speed


func calculate_movement_parameters() -> void:
	jump_gravity = (2*jump_height)/pow(jump_peak_time,2)
	fall_gravity = (2*jump_height)/pow(jump_fall_time,2)
	jump_velocity = jump_gravity * jump_peak_time
	base_speed = jump_distance/(jump_peak_time+jump_fall_time)
	_speed = base_speed


func _physics_process(_delta: float) -> void:
	#sprint_replenish(_delta)
	#lean_collision()

	# Add the gravity.
	var _acceleration
	if not player.is_on_floor():
		_acceleration = acceleration*air_acceleration_modifier
		
		if coyote_timer.is_stopped():
			coyote_timer.start(coyote_time)
	
		if player.velocity.y>0:
			player.velocity.y -= jump_gravity * _delta
		else:
			player.velocity.y -= fall_gravity * _delta
	else:
		_acceleration = acceleration
		jump_available = true
		coyote_timer.stop()
		_speed = (base_speed / max((float(crouched)*crouch_speed_reduction),1)) * speed_modifier
		if jump_buffer:
			jump()
			jump_buffer = false
		
	# Continuous check to auto-uncrouch once the ceiling obstacle clears
	if crouched and crouch_blocked:
		if crouch_collider and !crouch_collider.is_colliding():
			crouch_blocked = false
			if !Input.is_action_pressed("crouch"):
				crouch()
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if jump_available:
			if crouched:
				crouch()
			else:
				jump()
		else:
			jump_buffer = true
			get_tree().create_timer(jump_buffer_time).timeout.connect(on_jump_buffer_timeout)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	player.velocity.x = move_toward(player.velocity.x, direction.x * _speed, _acceleration*_delta)
	player.velocity.z = move_toward(player.velocity.z, direction.z * _speed, _acceleration*_delta)
	
	player.move_and_slide()


#func crouch() -> void:
	#player.anim_player.play("crouch")
	#crouched = true


func crouch() -> void:
	var blend_val
	if !crouch_collider.is_colliding():
		if crouched:
			blend_val = STANDING
		else:
			speed_modifier = NORMAL_speed
			exit_sprint()
			
			if player.is_on_floor():
				blend_val = GROUND_CROUCH
			else:
				blend_val = AIR_CROUCH
				
		if player.animation_tree:
			var blend_tween = get_tree().create_tween()
			blend_tween.tween_property(player.animation_tree, 
			"parameters/Crouch_Blend/blend_amount", 
			blend_val, crouch_blend_speed)
			
		crouched = !crouched
	else:
		crouch_blocked = true


func exit_sprint() -> void:
	if !sprint_timer.is_stopped():
		sprint_time_remaining = sprint_timer.time_left
		sprint_timer.stop()


func sprint_replenish(delta) -> void:
	var sprint_bar_Value


	if !sprint_on_cooldown and (speed_modifier != sprint_speed):
		
		if player.is_on_floor():
			sprint_time_remaining = move_toward(sprint_time_remaining, sprint_time, delta*sprint_replenish_rate)
			
		sprint_bar_Value = (sprint_time_remaining/sprint_time)*100
		
	else:
		sprint_bar_Value = (sprint_timer.time_left/sprint_time)*100
	
	sprint_bar.value = sprint_bar_Value
	
	if sprint_bar_Value == 100:
		sprint_bar.hide()
	else:
		sprint_bar.show()



func jump()->void:
	player.velocity.y = jump_velocity
	jump_available = false

func _on_sprint_timer_timeout() -> void:
	sprint_on_cooldown = true
	get_tree().create_timer(sprint_cooldown_time).timeout.connect(_on_sprint_cooldown_timeout)
	speed_modifier = NORMAL_speed
	sprint_time_remaining = 0

func _on_sprint_cooldown_timeout():
	sprint_on_cooldown = false

func _on_coyote_timer_timeout() -> void:
	jump_available = false

func on_jump_buffer_timeout()->void:
	jump_buffer = false
