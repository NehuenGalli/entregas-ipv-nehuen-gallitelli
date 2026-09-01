extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.set_projectile_container(self)
	get_tree().call_group("turrets", "set_values", $Player, self)
