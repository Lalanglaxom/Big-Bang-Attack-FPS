extends CharacterBody3D
class_name Entity

@export var hurtbox_list: Array[HurtBox]

#const SPEED = 5.0
#const JUMP_VELOCITY = 10

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_text: Label3D = $HealthText
@onready var components: Node = $Components

var health: int = 100

func _ready() -> void:
	for hurtbox in hurtbox_list:
		if hurtbox.has_method("init"):
			hurtbox.init(self)
		else:
			printerr(str(hurtbox) + "Has no init method")
		
	for comp in components.get_children():
		if comp.has_method("init"):
			comp.init(self)
		else:
			printerr(str(comp) + "Has no init method")

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
