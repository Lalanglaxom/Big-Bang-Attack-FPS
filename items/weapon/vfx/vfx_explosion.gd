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
	query.transform = global_transform
	query.collision_mask = 1

	var space_state = get_world_3d().direct_space_state
	var results = space_state.intersect_shape(query)

	for result in results:
		var body = result.collider
		if body is Player or body.is_in_group("Player"):
			# Uses your Player script's collider variable directly
			if body.collider:
				_launch_player_capsule(body, body.collider)


func _launch_player_capsule(player: Player, col_shape: CollisionShape3D) -> void:
	# Target the exact center midpoint of the player's collision shape
	var target_center: Vector3 = col_shape.global_position

	# Calculate blast vector directly from explosion center to shape midpoint
	var blast_vec = target_center - global_position
	var distance = blast_vec.length()

	# Range Check
	if distance > blast_radius:
		return

	var blast_dir: Vector3

	# Zero-Distance / Point-Blank Guard (World-Space, camera independent)
	if distance < 0.2:
		if global_position.y > target_center.y:
			# Explosion is above player center -> Push straight DOWN
			blast_dir = Vector3.DOWN
		else:
			# Explosion is below/beside player center -> Push straight UP
			blast_dir = Vector3.UP
		distance = 0.2
	else:
		blast_dir = blast_vec.normalized()

	# Apply y_bias ONLY when pushing UPWARDS (prevents ceiling shots from getting X/Z drift)
	if blast_dir.y > 0.0:
		blast_dir.y += y_bias
		blast_dir = blast_dir.normalized()

	# Linear distance falloff
	var falloff = 1.0 - (distance / blast_radius)
	var final_velocity = blast_dir * force * falloff

	if player.movement and player.movement.has_method("add_explosion_knockback"):
		player.movement.add_explosion_knockback(final_velocity)


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
