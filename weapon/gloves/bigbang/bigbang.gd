extends RigidBody3D

@export var speed = 20 

@onready var explosion = preload("res://weapon/gloves/bigbang/bigbang_vfx.tscn")

var projectile_path
var instance

func _ready():
	projectile_path = Global.projectile_path.normalized()

func _physics_process(delta):
	global_position += projectile_path * speed * delta
	
#

func _on_body_entered(body):
	instance = explosion.instantiate()
	instance.position = global_position
	Global.root.add_child(instance)
	queue_free()
	
