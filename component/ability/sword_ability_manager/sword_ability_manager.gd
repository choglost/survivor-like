extends Node

@export var sword_rage: float = 150

@export var base_wait_time: float = 1.5

@export_range(0, 1) var percent_reduction: float = 0.1

@export var sword_ablity: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get_node("Timer") # 找到子节点
	$Timer.wait_time = base_wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

# 冷却结束，触发攻击
func on_timer_timeout() -> void:
	# print("timeout")
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var enemies = get_tree().get_nodes_in_group("enemy")
	
	enemies = enemies.filter(func(enemy: Node2D):
			return enemy.global_position.distance_squared_to(player.global_position) < pow(sword_rage, 2)
	)

	if enemies.size() == 0:
		return
	
	enemies.sort_custom(
		func(a: Node2D, b: Node2D):
			var a_distance = a.global_position.distance_squared_to(player.global_position)
			var b_distance = b.global_position.distance_squared_to(player.global_position)
			return a_distance < b_distance
	)

	var sword_instance = sword_ablity.instantiate() as Node2D

	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")

	foreground_layer.add_child(sword_instance)
	var enemy_direction = enemies[0].global_position - player.global_position

	sword_instance.global_position = player.global_position + enemy_direction * 0.8
	sword_instance.rotation = enemy_direction.angle()

# 技能升级
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_rate":
		$Timer.wait_time = base_wait_time * (1 - percent_reduction * current_upgrades["sword_rate"]["quantity"])
		$Timer.start() # 重置循环时间
		print("sword_rate已升级")
	else:
		return
