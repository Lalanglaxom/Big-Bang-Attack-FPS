extends Node3D

@onready var emitters = [$Spark, $Flash, $Fire, $Smoke]
var lifeTime: float = 0.0

@export var force: float = 25.0
@export var damage: int = 20
@export var blast_radius: float = 5.0

@export var y_bias: float = 0.5

func _ready() -> void:
	startEmitters()
	getLifetime()
	
	# Clean up after lifetime ends
	await get_tree().create_timer(max(0.01, lifeTime)).timeout
	disposeOfEmitters()
	queue_free()


## Explicit trigger method called by the Rocket script AFTER global_position is set
func trigger_explosion(impact_point: Vector3) -> void:
	global_position = impact_point
	_apply_explosion_force()


func _apply_explosion_force() -> void:
	var sphere = SphereShape3D.new()
	sphere.radius = blast_radius

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	# Uses global_transform after trigger_explosion updates global_position
	query.transform = global_transform
	query.collision_mask = 1  # Scans all collision layers

	var space_state = get_world_3d().direct_space_state
	var results = space_state.intersect_shape(query)

	for result in results:
		var body = result.collider
		if body is Player or body.is_in_group("Player"):
			_launch_player(body)



func _launch_player(player: Node3D) -> void:
	# Vector from ACTUAL impact point to player center
	var blast_vec = player.global_position - global_position
	var distance = blast_vec.length()

	# If player is outside blast radius, ignore launch
	if distance > blast_radius:
		return

	# Corner / Zero-Distance Guard: If shot lands right against/inside player collision
	var blast_dir: Vector3
	if distance < 0.2:
		var cam = get_viewport().get_camera_3d()
		if cam:
			blast_dir = -cam.global_transform.basis.z + Vector3(0, 0.4, 0)
		else:
			blast_dir = Vector3.UP
		distance = 0.2
	else:
		blast_dir = blast_vec.normalized()

	# Moderate vertical boost bias
	blast_dir.y += y_bias
	blast_dir = blast_dir.normalized()

	# Linear distance falloff (1.0 at impact point, 0.0 at edge of blast_radius)
	var falloff = 1.0 - (distance / blast_radius)
	var final_velocity = blast_dir * force * falloff

	if player.has_method("add_explosion_knockback"):
		player.add_explosion_knockback(final_velocity)
	elif "velocity" in player:
		player.velocity += final_velocity


func getLifetime() -> void:
	for emitter in emitters:
		if emitter and emitter.lifetime > lifeTime:
			lifeTime = emitter.lifetime


func startEmitters() -> void:
	for emitter in emitters:
		if emitter:
			emitter.emitting = true


func disposeOfEmitters() -> void:
	for emitter in emitters:
		if emitter:
			emitter.queue_free()
