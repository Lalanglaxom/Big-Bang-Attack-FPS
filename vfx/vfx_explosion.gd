extends Node3D

@onready var emitters = [$Spark,$Flash,$Fire,$Smoke]
var lifeTime = 0
@export var force = 10
@export var damage = 20

func _ready():
	startEmitters()
	getLifetime()
	await get_tree().create_timer(lifeTime).timeout
	disposeOfEmitters()
	queue_free()

func getLifetime():
	for emitter in emitters:
		if emitter.lifetime > lifeTime:
			lifeTime = emitter.lifetime


func startEmitters():
	for emitter in emitters:
		emitter.emitting = true


func disposeOfEmitters():
	for emitter in emitters:
		emitter.queue_free()


func _on_rocket_3d_body_entered(body):
	if body.is_in_group("enemies"):
		Global.on_enemy_hit.emit(body, damage)


func _on_area_3d_body_entered(body):
	if body.is_in_group("enemies"):
		Global.on_enemy_hit.emit(body, damage)
