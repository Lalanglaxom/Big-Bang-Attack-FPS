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

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var PAUSE : String = "ui_cancel"
@export var LEFT : String = "left"
@export var RIGHT : String = "right"
@export var UP : String = "up"
@export var DOWN : String = "down"
@export var DODGE : String = "dodge"
@export var ATTACK : String = "attack"

@export_group("Others")
@onready var view_model_cam = $Head/Camera/SubViewportContainer/SubViewport/view_model_cam
@onready var fps_rig: Node3D = $Head/Camera/SubViewportContainer/SubViewport/view_model_cam/FPS_Rig
@onready var main = $".."

var canAtack: bool = true

# Member variables

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
	CAMERA.look_at(TARGET.global_position)
	handle_movement(delta)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	$UserInterface/DebugPanel.add_property("FPS", 1.0/delta, 0)
	
	handle_game_input()
	handle_state()


func handle_movement(delta):
	
	move_and_slide()

func handle_game_input():
	var input_dir = Input.get_vector("left", "right", "down", "up")
	if Input.is_action_just_pressed("attack"):
		#print("ATTACK")
		return
	
	if Input.is_action_just_pressed("parry"):
		print("PARRY")
		
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

func take_damage(attack: Attack):
	if cur_stand in attack.atk_stand:
		print("get hit")
