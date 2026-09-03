extends Node3D

@export var speed: float = 40.0
@export var lifetime: float = 5.0

@onready var ray_cast: RayCast3D = $RayCast3D

var time_alive: float = 0.0
const VFX_EXPLOSION = preload("uid://c7tpfpuxtinqa")


## Call this immediately after spawning the rocket
func setup_target(spawn_position: Vector3) -> void:
	global_position = spawn_position
	
	var camera = get_viewport().get_camera_3d()
	if camera:
		# Rocket simply flies straight along the camera's view direction
		global_transform.basis = camera.global_transform.basis


func _physics_process(delta: float) -> void:
	var move_distance = speed * delta
	
	# Dynamically scale raycast length to match exact movement distance for this frame
	ray_cast.target_position = Vector3(0, 0, -move_distance)
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		var hit_collider = ray_cast.get_collider()
		if not hit_collider.is_in_group("Player"):
			var hit_point = ray_cast.get_collision_point()
			var hit_normal = ray_cast.get_collision_normal()
			explode(hit_point, hit_normal)
			return
			
	# Move rocket forward
	global_position -= global_transform.basis.z * move_distance
	
	time_alive += delta
	if time_alive >= lifetime:
		# If it times out in mid-air, explode at current rocket position
		explode(global_position, global_transform.basis.z)


func explode(impact_position: Vector3, impact_normal: Vector3 = Vector3.UP) -> void:
	var vfx = VFX_EXPLOSION.instantiate()
	get_tree().current_scene.add_child(vfx)
	
	vfx.trigger_explosion(impact_position)
	
	# Align explosion VFX along the surface normal
	if impact_normal != Vector3.ZERO and impact_normal != Vector3.UP:
		vfx.look_at(impact_position + impact_normal, Vector3.UP)
		
	queue_free()
