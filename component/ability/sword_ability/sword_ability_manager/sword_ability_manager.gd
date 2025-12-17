extends Node

@export var sword_rage:float = 150

@export var sword_ablity: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get_node("Timer") # 找到子节点
	$Timer.timeout.connect(on_timeout)

func on_timeout() -> void:	
	# print("timeout")
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: return

	var enemies = get_tree().get_nodes_in_group("enemy")
	
	enemies=enemies.filter(func(enemy:Node2D):
			return enemy.global_position.distance_squared_to(player.global_position) < pow(sword_rage,2)
	)
	if enemies.size() == 0: return
	enemies.sort_custom(
		func(a:Node2D,b:Node2D):
			var a_distance = a.global_position.distance_squared_to(player.global_position)
			var b_distance = b.global_position.distance_squared_to(player.global_position)
			return a_distance < b_distance
	)

	var sword_instance = sword_ablity.instantiate() as Node2D
	player.get_parent().add_child(sword_instance)
	sword_instance.global_position = enemies[0].global_position

	var enemy_direction = enemies[0].global_position - player.global_position
	sword_instance.rotation = enemy_direction.angle()
