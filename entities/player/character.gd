extends CharacterBody3D

## Gameplay properties
@export var health: float = 100


@export_group("Nodes")
@export var HEAD : Node3D
@export var camera : Camera3D
@export var CAMERA_ANIMATION : AnimationPlayer
@export var TARGET: Node3D


@export_group("Others")
@onready var view_model_cam = $Head/Camera/SubViewportContainer/SubViewport/view_model_cam
@onready var fps_rig: Node3D = $Head/Camera/SubViewportContainer/SubViewport/view_model_cam/FPS_Rig
@onready var main = $".."

var camera_rotation: Vector2 = Vector2(0.0,0.0)
var mouse_sensitivity = 0.001

# We are using UI controls because they are built into Godot Engine so they can be used right away
var PAUSE : String = "ui_cancel"
var LEFT : String = "left"
var RIGHT : String = "right"
var UP : String = "up"
var DOWN : String = "down"
var DODGE : String = "dodge"
var ATTACK : String = "attack"
var canAtack: bool = true

@export var _animation_tree: AnimationTree

# UI
@onready var health_text = $UserInterface/HealthText


# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Head/Camera/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()

func _physics_process(delta):
	#CAMERA.look_at(TARGET.global_position)
	handle_movement(delta)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative * mouse_sensitivity
		camera_look(MouseEvent)

#func _process(delta):
	#if Input.is_action_just_pressed("ui_cancel"):
		#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	#handle_game_input()
	#handle_state()
	#text_debugger()
	


func camera_look(Movement: Vector2) -> void:
	camera_rotation += Movement
	
	transform.basis = Basis()
	camera.transform.basis = Basis()
	
	rotate_object_local(Vector3(0,1,0),-camera_rotation.x) # first rotate in Y
	camera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y) # then rotate in X
	camera_rotation.y = clamp(camera_rotation.y,-1.5,1.2)


func handle_movement(delta):
	move_and_slide()

func handle_game_input():
	var input_dir = Input.get_vector("left", "right", "down", "up")
	if Input.is_action_just_pressed("attack"):
		#print("ATTACK")
		return
		
	if Input.is_action_just_pressed("dodge"):
		print("DODGE")
	
	#print(CharacterStand.keys()[cur_stand])
	
func handle_state():
	return

func start():
	pass
