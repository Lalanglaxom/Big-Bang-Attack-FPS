class_name Attack

var atk_stand: Array[String]
var atk_damage: int
var atk_anim_name: String
var isBeam: bool

func _init(damage: int, stand: Array[String], anim_name: String, isBeam: bool) -> void:
	self.atk_damage = damage
	self.atk_stand = stand
	self.atk_anim_name = anim_name
	self.isBeam = isBeam
