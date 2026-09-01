extends CanvasLayer
class_name PlayerHUD

var player: Player

@onready var health_label: Label = $HealthText
@onready var interact_label: Label = $InteractText


func init(new_player: Player):
	player = new_player


func set_interact_text(value: String):
	interact_label.text = value
