extends Node
class_name Utils

static func remove_all_child(parent_node: Node):
	for child in parent_node.get_children():
			child.queue_free()
