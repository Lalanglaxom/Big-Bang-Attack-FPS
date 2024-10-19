extends CharacterBody3D

## Gameplay properties
@export var health: float = 100
enum CharacterStand {LEFT, RIGHT, UP, DOWN, CENTER}
@export var cur_stand: CharacterStand
@export var start_pos: Vector3


@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var CAMERA_ANIMATION : AnimationPlayer
@export var TARGET: Node3D

@export_group("Time/Amount")
@export var parry_star_amount: float = 20
@export var dodge_star_amount: float = 10
@export var vanish_star_amount: float = 10

@export var parry_cooldown_time: float = 2.3
@onready var parry_cooldown_timer: Timer = $ParryCooldown
var parry_timer: float = 0
var is_cooldown: bool = false

@export var vanish_cooldown: float = 0.2


@export_group("Others")
@onready var view_model_cam = $Head/Camera/SubViewportContainer/SubViewport/view_model_cam
@onready var fps_rig: Node3D = $Head/Camera/SubViewportContainer/SubViewport/view_model_cam/FPS_Rig
@onready var main = $".."

# We are using UI controls because they are built into Godot Engine so they can be used right away
var PAUSE : String = "ui_cancel"
var LEFT : String = "left"
var RIGHT : String = "right"
var UP : String = "up"
var DOWN : String = "down"
var DODGE : String = "dodge"
var ATTACK : String = "attack"
var canAtack: bool = true

# Get state chart 
@onready var _state_chart = $StateChart
@export var _animation_tree: AnimationTree

# UI
@onready var health_text = $UserInterface/HealthText
@onready var texture_progress_bar = $UserInterface/TextureProgressBar
@onready var star_progress_bar: TextureProgressBar = $UserInterface/StarProgressBar
@onready var parry_cooldown_label: Label = $"UserInterface/Parry Cooldown"


# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Head/Camera/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()

	Global.on_parry_success.connect(parry_success.bind(parry_star_amount))
	Global.on_parry_failed.connect(parry_missed)

func _physics_process(delta):
	CAMERA.look_at(TARGET.global_position)
	handle_movement(delta)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	handle_game_input()
	handle_state()
	text_debugger()

func handle_movement(delta):
	
	move_and_slide()

func handle_game_input():
	var input_dir = Input.get_vector("left", "right", "down", "up")
	if Input.is_action_just_pressed("attack"):
		#print("ATTACK")
		return
	
	if Input.is_action_just_pressed("parry"):
		parry()
		
	if Input.is_action_just_pressed("dodge"):
		print("DODGE")
		
	if Input.is_action_pressed("up"):
		view_model_cam.sway("up")
		cur_stand = CharacterStand.UP
	elif Input.is_action_pressed("down"):
		view_model_cam.sway("down")
		cur_stand = CharacterStand.DOWN
	elif Input.is_action_pressed("left"):
		view_model_cam.sway("left")
		cur_stand = CharacterStand.LEFT
	elif Input.is_action_pressed("right"):
		view_model_cam.sway("right")
		cur_stand = CharacterStand.RIGHT
	else:
		cur_stand = CharacterStand.CENTER
	
	#print(CharacterStand.keys()[cur_stand])
	
func handle_state():
	return

func start():
	global_position = start_pos


func increase_star(amount: float):
	star_progress_bar.value += amount
	if star_progress_bar.value == star_progress_bar.max_value:
		print("FUCK YOU KI KO HOUUUUUUUUUUUUU")


func take_damage(attack: Attack):
	if CharacterStand.keys()[cur_stand] in attack.atk_stand:
		print("get hit: " + str(attack.atk_damage) + " damage")
		health -= attack.atk_damage
		health = max(health, 0)
		texture_progress_bar.value = health
		health_text.text = str(health)
		return
	
	increase_star(dodge_star_amount)

func parry():
	if is_cooldown:
		return
	
	Global.on_parry_pressed.emit()


func parry_success(star_amount: float):
	is_cooldown = false
	increase_star(star_amount)


func parry_missed():
	parry_cooldown_timer.wait_time = parry_cooldown_time
	parry_cooldown_timer.start()
	is_cooldown = true



func _on_parry_cooldown_timeout() -> void:
	is_cooldown = false


func text_debugger():
	parry_cooldown_label.text = "Parry dooldown: " + str(snapped(parry_cooldown_timer.time_left,0.01))
