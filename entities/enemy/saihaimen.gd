extends CharacterBody3D

var health = 50
var speed = 6
@onready var agent = $NavigationAgent3D

var damage = 20
var target
var rng = RandomNumberGenerator.new()

@onready var explosion = preload("res://vfx/explosion/vfx_explosion.tscn")
var instance

func _ready():
	Global.on_enemy_hit.connect(take_damage)
	target = Vector3(0,0,0)

func _physics_process(delta):
	
	var next_path_position: Vector3 = agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	velocity = velocity.move_toward(new_velocity, 0.25) 
	
	look_at(Vector3(target.x,global_position.y,target.z))
	move_and_slide()

func update_target(player):
	#target = get_node(player)
	agent.set_target_position(player.global_position)
	target = player.global_position
	
	
func _on_navigation_agent_3d_target_reached():
	instance = explosion.instantiate()
	instance.position = global_position
	get_tree().get_root().get_child(0).add_child(instance)
	Global.on_hit.emit(damage)
	Global.on_enemy_die.emit()
	queue_free()


func take_damage(body, damage):
	if body == self:
		health -= damage
		if health <= 0:
			Global.on_enemy_die.emit()
			queue_free()
	
