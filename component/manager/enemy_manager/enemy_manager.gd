extends Node
## 生成半径
@export var spawn_radius: float = 250
## 老鼠敌人
@export var rat_enemy_scene: PackedScene
## 巫师敌人
@export var wizard_enemy_scene: PackedScene
## 时间管理器
@export var arena_time_manager: Node

@onready var timer = $Timer

@onready var player = get_tree().get_first_node_in_group("player") as Node2D

var base_spawn_time = 0

var enemy_table = WeightedTable.new()

func _ready() -> void:
  enemy_table.add_item(rat_enemy_scene, 10)
  base_spawn_time = timer.wait_time
  timer.timeout.connect(on_timer_timeout)
  arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func on_timer_timeout() -> void:
  timer.start()

  if player == null:
    return

  var enemy_scene = enemy_table.pick_item()
  var enemy_instance = enemy_scene.instantiate() as Node2D

  var entities_layer = get_tree().get_first_node_in_group("entities_layer")
  entities_layer.add_child(enemy_instance)
  enemy_instance.global_position = get_spawn_position()


func get_spawn_position() -> Vector2:
  if player == null:
    return Vector2.ZERO
  
  var spawn_position = Vector2.ZERO
  var random_direction = Vector2.RIGHT.rotated(randf_range(0, PI * 2))
  for i in 4:
    spawn_position = player.global_position + random_direction * spawn_radius

    var query_paramaters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
    var query_result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_paramaters)

    if query_result.is_empty():
      break
    else:
      random_direction = random_direction.rotated(PI / 2)
  
  return spawn_position


func on_arena_difficulty_increased(arena_difficulty: int) -> void:
  var time_off = (.1 / 12) * arena_difficulty
  time_off = min(time_off, .7)
  timer.wait_time = base_spawn_time - time_off

  # 20秒后刷巫师怪
  if arena_difficulty == 4:
    enemy_table.add_item(wizard_enemy_scene, 10)


# extends Node

# @export var enemy_scene: PackedScene

# # 刷怪距离（相对于屏幕边缘）
# @export var spawn_margin: float = 64.0

# # 地图世界边界（必须设置）
# @export var world_rect: Rect2

# # 方向权重强度（0 = 不感知方向，1 = 强烈偏向）
# @export var direction_bias: float = 1.0


# func _ready() -> void:
#   $Timer.timeout.connect(_on_timer_timeout)


# func _on_timer_timeout() -> void:
#   var player := get_tree().get_first_node_in_group("player") as Node2D
#   if player == null:
#     return

#   var spawn_pos := get_spawn_position(player)

#   var enemy := enemy_scene.instantiate() as Node2D
#   var entities_layer := get_tree().get_first_node_in_group("entities_layer")
#   entities_layer.add_child(enemy)
#   enemy.global_position = spawn_pos

# func get_spawn_position(player: Node2D) -> Vector2:
#   var screen := get_screen_rect()
#   var move_dir := get_player_move_dir(player)
#   var side := choose_side(move_dir)

#   var pos := generate_position_on_side(screen, side)

#   # 防止越界
#   pos.x = clamp(pos.x, world_rect.position.x, world_rect.end.x)
#   pos.y = clamp(pos.y, world_rect.position.y, world_rect.end.y)

#   return pos

# func get_screen_rect() -> Rect2:
#   var cam := get_viewport().get_camera_2d()
#   var screen_rect: Rect2 = get_viewport().get_visible_rect()
#   var size := screen_rect.size
#   var top_left := cam.global_position - size * 0.5
#   return Rect2(top_left, size)

# var _last_player_pos: Vector2

# func get_player_move_dir(player: Node2D) -> Vector2:
#   if _last_player_pos == Vector2.ZERO:
#     _last_player_pos = player.global_position
#     return Vector2.ZERO

#   var dir := player.global_position - _last_player_pos
#   _last_player_pos = player.global_position

#   return dir.normalized()

# func choose_side(move_dir: Vector2) -> int:
#   # 0 上，1 下，2 左，3 右
#   var weights := [
#     max(0.0, -move_dir.y) * direction_bias,
#     max(0.0, move_dir.y) * direction_bias,
#     max(0.0, -move_dir.x) * direction_bias,
#     max(0.0, move_dir.x) * direction_bias,
#   ]

#   var total := 0.0
#   for w in weights:
#     total += w

#   # 玩家静止 → 均匀随机
#   if total <= 0.001:
#     return randi() % 4

#   var r := randf() * total
#   for i in 4:
#     r -= weights[i]
#     if r <= 0:
#       return i

#   return randi() % 4

# func generate_position_on_side(screen: Rect2, side: int) -> Vector2:
#   match side:
#     0: # 上
#       return Vector2(
#         randf_range(screen.position.x, screen.end.x),
#         screen.position.y - spawn_margin
#       )
#     1: # 下
#       return Vector2(
#         randf_range(screen.position.x, screen.end.x),
#         screen.end.y + spawn_margin
#       )
#     2: # 左
#       return Vector2(
#         screen.position.x - spawn_margin,
#         randf_range(screen.position.y, screen.end.y)
#       )
#     3: # 右
#       return Vector2(
#         screen.end.x + spawn_margin,
#         randf_range(screen.position.y, screen.end.y)
#       )
#     _:
#       return screen.position
