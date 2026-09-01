extends Sprite2D

@onready var fire_position:Marker2D = $FirePosition

@export var projectile_scene:PackedScene

var projectile_container:Node


func fire():
	var projectile_instance_Projectile = projectile_scene.instantiate()
	projectile_container.add_child(projectile_instance_Projectile)
	projectile_instance_Projectile.set_starting_values(fire_position.global_position, (fire_position.global_position - global_position))
	projectile_instance_Projectile.delete_requested.connect(_on_projectile_delete_requested)	
	
func _on_projectile_delete_requested(projectile):
	projectile_container.remove_child(projectile)
	projectile.queue_free()
