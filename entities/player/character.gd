extends CharacterBody3D
class_name Player

@export var camera: Camera3D
@export var gun_cam: Camera3D
@export var animation_tree: AnimationTree
@export var anim_player: AnimationPlayer
@onready var components: Node = $Components

var camera_rotation: Vector2 = Vector2(0.0,0.0)
var mouse_sensitivity = 0.001

@export_category("Components")
@onready var movement: PlayerMovement = $Components/Movement
@onready var input: PlayerInput = $Components/Input
@onready var combat: PlayerCombat = $Components/Combat
@onready var player_hud: PlayerHUD = $CanvasLayer

@onready var interact_cast: RayCast3D = %InteractCast

#var interactable: WeaponPickup

func _ready() -> void:
	update_camera_rotation()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	for comp in components.get_children():
		comp.init(self)
		
	player_hud.init(self)

func _process(delta: float) -> void:
	#if interact_cast.is_colliding():
		#var hit = interact_cast.get_collider() as WeaponPickup
		#player_hud.interact_label.visible = true
		#player_hud.set_interact_text(hit.interact_text)
		#interactable = hit
	#else:
	player_hud.interact_label.hide()
		#interactable = null
	pass


func _physics_process(delta: float) -> void:
	if gun_cam:
		gun_cam.global_transform = camera.global_transform


func update_camera_rotation() -> void:
	camera_rotation.x = -rotation.y
	camera_rotation.y = -camera.rotation.x


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative * mouse_sensitivity
		camera_look(MouseEvent)


func camera_look(Movement: Vector2) -> void:
	camera_rotation += Movement
	
	transform.basis = Basis()
	camera.transform.basis = Basis()
	
	rotate_object_local(Vector3(0,1,0),-camera_rotation.x) # first rotate in Y
	camera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y) # then rotate in X
	camera_rotation.y = clamp(camera_rotation.y,-1.5,1.5)
