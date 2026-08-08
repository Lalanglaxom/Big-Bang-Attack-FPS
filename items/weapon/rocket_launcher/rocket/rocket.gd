extends RigidBody3D

@export var rocket_speed = 20 

@onready var explosion = preload("res://vfx/explosion/vfx_explosion.tscn")

var projectile_path
var instance


func _ready():
	projectile_path = Global.projectile_path.normalized()

func _physics_process(delta):
	global_position += projectile_path * rocket_speed * delta
	
#
func _on_body_entered(body):
	instance = explosion.instantiate()
	instance.position = global_position
	get_tree().get_root().get_child(0).add_child(instance)
	queue_free()
	
