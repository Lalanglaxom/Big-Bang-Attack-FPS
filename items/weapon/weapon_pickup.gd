extends Area3D
class_name WeaponPickup


@export var weapon_scene: PackedScene
@export var weapon_name: String
@export var interact_text: String = "Press E to pick up"
@onready var label_3d: Label3D = $Label3D


func _ready() -> void:
	if not weapon_scene:
		push_warning("WeaponPickup: No weapon_asset assigned!")
		return
	
	label_3d.text = weapon_name
	_setup_pickup_mesh()


func interact(player: Player):
	player.combat.equip(weapon_scene)


func _setup_pickup_mesh() -> void:
	# 1. Instantiate the asset
	var instance: Node = weapon_scene.instantiate()
	add_child(instance)
	
	# 2. Find all MeshInstance3D nodes and change visual layer to 1
	var meshes: Array[Node] = instance.find_children("*", "MeshInstance3D", true, false)
	for node in meshes:
		if node is MeshInstance3D:
			node.layers = 1
			
	# 3. Find and remove all AnimationPlayer nodes
	var anim_players: Array[Node] = instance.find_children("*", "AnimationPlayer", true, false)
	for anim_node in anim_players:
		anim_node.queue_free()
		
	# 4. Strip scripts from the root instance and all nested children
	_strip_scripts(instance)


func _strip_scripts(node: Node) -> void:
	node.set_script(null)
	for child in node.get_children():
		_strip_scripts(child)
