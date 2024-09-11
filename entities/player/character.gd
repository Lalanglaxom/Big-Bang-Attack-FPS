extends CharacterBody3D

# TODO: Add descriptions for each value
@export var health: float = 100

@export_category("Speed Force")
@export var base_speed : float = 3.0
@export var sprint_speed : float = 6.0
@export var crouch_speed : float = 1.0
@export var acceleration : float = 10.0
@export var mouse_sensitivity : float = 0.1
@export var to_crouch_speed : float = 1.0
@export var throwForce = 10.0

@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var CAMERA_ANIMATION : AnimationPlayer


@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var PAUSE : String = "ui_cancel"
@export var LEFT : String = "left"
@export var RIGHT : String = "right"
@export var UP : String = "up"
@export var DOWN : String = "down"
@export var DODGE : String = "dodge"
@export var ATTACK : String = "attack"

@export_group("Feature Settings")
@export var immobile : bool = false
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = true
@export var dynamic_fov : bool = true
@export var continuous_jumping : bool = true
@export var view_bobbing : bool = true

@export_group("Others")
@onready var view_model_cam = $Head/Camera/SubViewportContainer/SubViewport/view_model_cam
# @export var bomb = preload("res://weapon/bad_bomb.tscn")
@onready var main = $".."
var canShoot: bool = true

# Member variables
var speed : float = base_speed
var is_crouching : bool = false
var is_sprinting : bool = false

# Get state chart 
@onready var _state_chart = $StateChart
@export var _animation_tree: AnimationTree

# UI
@onready var health_text = $UserInterface/HealthText
@onready var texture_progress_bar = $UserInterface/TextureProgressBar
@onready var enemy_remain_text = $UserInterface/EnemyRemainText

# signal
signal shoot_button_clicked
signal health_depleted

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Head/Camera/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	
	Global.on_hit.connect(take_damage)

func _physics_process(delta):
	$Head/Camera/SubViewportContainer/SubViewport/view_model_cam.global_transform = CAMERA.global_transform

	# Add some debug data
	$UserInterface/DebugPanel.add_property("Movement Speed", speed, 1)
	$UserInterface/DebugPanel.add_property("Velocity", get_real_velocity(), 2)
	
	handle_state()


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	$UserInterface/DebugPanel.add_property("FPS", 1.0/delta, 0)
	
	handle_game_input()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		view_model_cam.sway(Vector2(event.relative.x, event.relative.y))
	
func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	move_and_slide()

func handle_game_input():
	var input_dir = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("attack"):
		print("ATTACK")
	
	if Input.is_action_just_pressed("parry"):
		print("PARRY")
		
	if Input.is_action_just_pressed("dodge"):
		print("DODGE")
		
func handle_state():
	if !is_on_floor():
		_state_chart.send_event("jump")
	else: 
		_state_chart.send_event("grounded")
		
	if is_sprinting:
		_state_chart.send_event("run")
	else:
		_state_chart.send_event("walk")
		
	
func take_damage(damage):
	health -= damage
	health_text.text = str(health)
	texture_progress_bar.value = health
	if health <= 0:
		health_depleted.emit()
