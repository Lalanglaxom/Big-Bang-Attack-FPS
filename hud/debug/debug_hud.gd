extends Control
class_name DebugHUD

var player: Player

@onready var x_velo: Label = $HBoxContainer/XVelo
@onready var y_velo: Label = $HBoxContainer/YVelo
@onready var z_velo: Label = $HBoxContainer/ZVelo

var start_debug: bool = false

func init(n_player: Player) -> void:
	player = n_player
	start_debug = true


func _physics_process(delta: float) -> void:
	if start_debug:
		# Rounding to 2 decimal places (0.01)
		x_velo.text = "X: " + str(snapped(player.velocity.x, 0.01))
		y_velo.text = "Y: " + str(snapped(player.velocity.y, 0.01))
		z_velo.text = "Z: " + str(snapped(player.velocity.z, 0.01))
