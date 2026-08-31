extends Node
class_name Director

@onready var spawn_point: Node3D = $SpawnPoint


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_epstein"):
		var epstein = Assets.EPSTEIN.instantiate() as Entity
		epstein.global_position = spawn_point.position
		get_parent().add_child(epstein)
