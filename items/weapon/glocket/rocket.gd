extends Node3D
class_name Projectile

@export var speed: float = 10.0
@export var lifetime: float = 5.0

@onready var mesh: MeshInstance3D = $Mesh
@onready var ray_cast: RayCast3D = $RayCast3D

var time_alive: float = 0.0
const VFX_EXPLOSION = preload("uid://c7tpfpuxtinqa")


## Call this immediately after spawning the rocket
func setup_target(spawn_position: Vector3, muzzle_position: Vector3) -> void:
	# 1. Place physics root at camera spawn position
	global_position = spawn_position
	
	var camera = get_viewport().get_camera_3d()
	if camera:
		# Align physics root with camera rotation
		global_transform.basis = camera.global_transform.basis
		
	# 2. Visually place the mesh model at the muzzle position
	mesh.global_position = muzzle_position
	
	# 3. Smoothly slide the mesh model onto the physics root over 0.08 seconds
	var tween = create_tween()
	tween.tween_property(mesh, "position", Vector3.ZERO, 0.2)\
		 .set_trans(Tween.TRANS_QUAD)\
		 .set_ease(Tween.EASE_OUT)


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
