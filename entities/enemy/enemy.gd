extends CharacterBody3D
class_name Enemy


@export var hurtbox_list: Array[HurtBox]

#const SPEED = 5.0
#const JUMP_VELOCITY = 10

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

#@onready var player = get_tree().get_nodes_in_group("player")[0]

func _ready() -> void:
	pass


#func _physics_process(delta: float) -> void:
	#look_at(player.global_position)
	#rotation.x = 0
	#rotation.z = 0
#
	#update_wait_time(delta)
	#handle_movement()
#
#
#func handle_movement():
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * get_physics_process_delta_time()
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	#time += get_physics_process_delta_time()
	#
	#var direction := (transform.basis * Vector3(walk_speed, 0, approach_speed))
	#
	#if lock_movement:
		#direction = Vector3.ZERO
		#
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	#
	#if position.distance_to(player.position) < 4:
		#if approach_speed < 0:
			#lock_movement = true
			#
	#if position.distance_to(player.position) >= base_distance:
		#if approach_speed > 0:
			#approach_speed = 0
		#
	#move_and_slide()


#func damage(attack: Attack):
	#player.take_damage(attack)
#
#
#func call_damage():
	#damage(attack)
	#can_be_parry = false


func take_damage(attack: Attack):
	animation_player.play("hit")


#func add_attack_object(new_attack: Attack):
	#if !new_attack.isBeam:
		#skill_array.append(new_attack)
	#else:
		#beam_array.append(new_attack)
#
#func change_attack(new_attack: Attack):
	#attack = new_attack
#
#
#func update_wait_time(delta):
	#time += delta
	#if time >= 5:
		#moving_timer.wait_time = randf_range(2,5)
		#time = 0
		#
		#
#func on_distance_timer_timeout() -> void:
	#walk_speed *= -1
#
#
#func on_attack_timer_timeout() -> void:
	#print("Attack")
#
#
#func on_animation_finished(anim_name: StringName) -> void:
	#pass
#
#
#func handle_state():
	#return
#
#
#func create_parry_timing(anim_name: String, hit_time: float, parry_window: float):
	#var animation = animation_player.get_animation(anim_name)
	#var track_index = animation.add_track(Animation.TYPE_METHOD)
	#var method_dictionary = {
		#"method": "enable_parry",
		#"args": [],
	#}
#
	#animation.track_set_path(track_index, ".")
	#animation.track_insert_key(track_index, hit_time - parry_window, method_dictionary, 0)
#
#
## The target method that will be called from the animation.
#func enable_parry():
	#can_be_parry = true
#
#
#func get_parry():
	#if can_be_parry:
		#animation_player.play("RESET")
		#Events.on_parry_success.emit()
		#can_be_parry = false
	#else:
		#Events.on_parry_failed.emit()
