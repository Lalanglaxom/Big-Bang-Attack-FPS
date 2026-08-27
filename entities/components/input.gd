extends Node
class_name InputComponent

signal on_shoot_clicked

var player: Player

func init(new_player: Player) -> void:
	player = new_player

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			player.combat.shoot_weapon()
