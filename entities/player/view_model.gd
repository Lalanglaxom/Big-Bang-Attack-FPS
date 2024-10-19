extends Camera3D

		
@export var animation_tree: AnimationTree 

@onready var fps_rig = $FPS_Rig
@onready var state_chart = $"../../../../../StateChart"

@export var lerp_speed: int = 5

func _ready():
	pass

func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta * lerp_speed)
	fps_rig.position.y = lerp(fps_rig.position.y, 0.0, delta * lerp_speed)


func sway(direction: String):
	match direction:
		"up":
			fps_rig.position.y = lerp(fps_rig.position.y, 0.1, get_process_delta_time() * lerp_speed)
		"down":
			fps_rig.position.y = lerp(fps_rig.position.y, -0.05, get_process_delta_time() * lerp_speed)
		"left":
			fps_rig.position.x = lerp(fps_rig.position.x, -0.1, get_process_delta_time() * lerp_speed)
		"right":
			fps_rig.position.x = lerp(fps_rig.position.x, 0.1, get_process_delta_time() * lerp_speed)


func _on_run_state_entered():
	animation_tree["parameters/conditions/walk"] = false
	animation_tree["parameters/conditions/run"] = true


func _on_walk_state_entered():
	animation_tree["parameters/conditions/run"] = false
	animation_tree["parameters/conditions/walk"] = true


func _on_animation_tree_animation_player_changed():
	var state_machine = animation_tree.get("parameters/playback")
	state_machine.travel("Enter")


func _on_character_shoot_button_clicked():
	var state_machine = animation_tree.get("parameters/playback")
	state_machine.travel("Shoot")
