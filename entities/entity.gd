extends CharacterBody3D
class_name Entity

@export var hurtbox_list: Array[HurtBox]

#const SPEED = 5.0
#const JUMP_VELOCITY = 10

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_text: Label3D = $HealthText

var health: int = 100

func _ready() -> void:
	for hurtbox in hurtbox_list:
		hurtbox.init(self)


func add_health(value: int):
	health += value
	health = clampi(health,0,100)
	
	anim_player.seek(0.0, true)
	anim_player.play("hit")
	
	health_text.text = "HP: %d" % [health]
	
	if health <= 0:
		anim_player.play("die")
		await anim_player.animation_finished
		queue_free()
