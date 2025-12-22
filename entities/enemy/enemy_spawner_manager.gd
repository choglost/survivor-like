# extends Node

# @export var spawn_radius: float = 330

# @export var enemy_scene: PackedScene

# func _ready() -> void:
# 	$Timer.timeout.connect(on_timer_timeout)


# func on_timer_timeout() -> void:
# 	var player = get_tree().get_first_node_in_group("player") as Node2D
# 	if player == null:
# 		return


# 	var random_direction = Vector2.RIGHT.rotated(randf_range(-PI, PI))
# 	var spawn_position = player.global_position + random_direction * spawn_radius

# 	var enemy = enemy_scene.instantiate() as Node2D
# 	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
# 	entities_layer.add_child(enemy)
# 	enemy.global_position = spawn_position

extends Node

@export var enemy_scene: PackedScene

# 刷怪距离（相对于屏幕边缘）
@export var spawn_margin: float = 64.0

# 地图世界边界（必须设置）
@export var world_rect: Rect2

# 方向权重强度（0 = 不感知方向，1 = 强烈偏向）
@export var direction_bias: float = 1.0


func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var spawn_pos := get_spawn_position(player)

	var enemy := enemy_scene.instantiate() as Node2D
	var entities_layer := get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = spawn_pos

func get_spawn_position(player: Node2D) -> Vector2:
	var screen := get_screen_rect()
	var move_dir := get_player_move_dir(player)
	var side := choose_side(move_dir)

	var pos := generate_position_on_side(screen, side)

	# 防止越界
	pos.x = clamp(pos.x, world_rect.position.x, world_rect.end.x)
	pos.y = clamp(pos.y, world_rect.position.y, world_rect.end.y)

	return pos

func get_screen_rect() -> Rect2:
	var cam := get_viewport().get_camera_2d()
	var screen_rect: Rect2 = get_viewport().get_visible_rect()
	var size := screen_rect.size
	var top_left := cam.global_position - size * 0.5
	return Rect2(top_left, size)

var _last_player_pos: Vector2

func get_player_move_dir(player: Node2D) -> Vector2:
	if _last_player_pos == Vector2.ZERO:
		_last_player_pos = player.global_position
		return Vector2.ZERO

	var dir := player.global_position - _last_player_pos
	_last_player_pos = player.global_position

	return dir.normalized()

func choose_side(move_dir: Vector2) -> int:
	# 0 上，1 下，2 左，3 右
	var weights := [
		max(0.0, -move_dir.y) * direction_bias,
		max(0.0, move_dir.y) * direction_bias,
		max(0.0, -move_dir.x) * direction_bias,
		max(0.0, move_dir.x) * direction_bias,
	]

	var total := 0.0
	for w in weights:
		total += w

	# 玩家静止 → 均匀随机
	if total <= 0.001:
		return randi() % 4

	var r := randf() * total
	for i in 4:
		r -= weights[i]
		if r <= 0:
			return i

	return randi() % 4

func generate_position_on_side(screen: Rect2, side: int) -> Vector2:
	match side:
		0: # 上
			return Vector2(
				randf_range(screen.position.x, screen.end.x),
				screen.position.y - spawn_margin
			)
		1: # 下
			return Vector2(
				randf_range(screen.position.x, screen.end.x),
				screen.end.y + spawn_margin
			)
		2: # 左
			return Vector2(
				screen.position.x - spawn_margin,
				randf_range(screen.position.y, screen.end.y)
			)
		3: # 右
			return Vector2(
				screen.end.x + spawn_margin,
				randf_range(screen.position.y, screen.end.y)
			)
		_:
			return screen.position
