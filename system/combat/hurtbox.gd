extends Area3D
class_name HurtBox

var entity: Entity

enum HurtType {HEAD, BODY}
@export var hurt_type: HurtType = HurtType.HEAD


func init(new_entity: Entity):
	entity = new_entity


func take_damage(damage: int):
	match hurt_type:
		HurtType.HEAD:
			entity.add_health(-damage * 2)
		HurtType.BODY:
			entity.add_health(-damage) 
