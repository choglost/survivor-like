extends Node

@export var spawn_radius: float = 330

@export var enemy_scene: PackedScene

func _ready() -> void:
	$Timer.timeout.connect(on_timer_timeout)


func on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return


	var random_direction = Vector2.RIGHT.rotated(randf_range(-PI, PI))
	var spawn_position = player.global_position + random_direction * spawn_radius

	var enemy = enemy_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = spawn_position
