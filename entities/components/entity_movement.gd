extends Node
class_name EntityMovement

@export_range(0.1, 10.0) var walk_speed: float = 3.0
@export var gravity_enabled: bool = true
@export var nav_agent: NavigationAgent3D

var player: Player = null
var entity: Entity

func init(new_entity: Entity) -> void:
	entity = new_entity
	
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0] as Player

	if nav_agent:
		nav_agent.avoidance_enabled = true
		# CONNECT SIGNAL: Receives velocity modified by RVO2 avoidance
		nav_agent.velocity_computed.connect(_on_velocity_computed)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not nav_agent:
		return

	nav_agent.target_position = player.global_position

	if nav_agent.is_navigation_finished():
		nav_agent.set_velocity(Vector3.ZERO)
		_apply_gravity(delta)
		entity.move_and_slide()
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_path_position - entity.global_position)
	direction.y = 0.0

	if direction.length_squared() > 0.01:
		direction = direction.normalized()
		var intended_velocity = direction * walk_speed
		
		# PASS TO NAVIGATION SERVER (Do not set entity.velocity directly!)
		nav_agent.set_velocity(intended_velocity)
		
		var look_target := Vector3(next_path_position.x, entity.global_position.y, next_path_position.z)
		entity.look_at(look_target, Vector3.UP)
	else:
		nav_agent.set_velocity(Vector3.ZERO)

	_apply_gravity(delta)


# THIS CALLBACK RECEIVES THE SAFE AVOIDANCE VELOCITY FROM NAVIGATION SERVER
func _on_velocity_computed(safe_velocity: Vector3) -> void:
	entity.velocity.x = safe_velocity.x
	entity.velocity.z = safe_velocity.z
	entity.move_and_slide()


func _apply_gravity(delta: float) -> void:
	if gravity_enabled and not entity.is_on_floor():
		entity.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
