extends Node
class_name PlayerInput

signal on_shoot_clicked

var player: Player

func init(new_player: Player) -> void:
	player = new_player

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			player.combat.shoot_cur_weapon()
	
	#if Input.is_action_just_pressed("interact"):
		#if player.interactable:
			#player.interactable.interact(player)
			
	if Input.is_action_just_pressed("weapon_up"):
		player.combat.equip_next()
	
	
	if Input.is_action_just_pressed("noclip"):
		player.movement.toggle_noclip()
