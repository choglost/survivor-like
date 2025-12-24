extends Node

## 攻击距离
@export var base_sword_rage: float = 150
## 初始冷却间隔
@export var base_wait_time: float = 1.5
## 当前冷却间隔
@export var current_wait_time: float = base_wait_time

@export_range(0, 1) var percent_reduction: float = 0.1
# 剑实体
@export var sword_ability_scene: PackedScene

var base_damage: float = 5
var current_damage: float = base_damage
var additional_damage: float = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  # get_node("Timer") # 找到子节点
  $Timer.wait_time = base_wait_time
  $Timer.timeout.connect(on_timer_timeout)
  GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


# 冷却结束，触发攻击
func on_timer_timeout() -> void:
  # 获取玩家节点
  var player = get_tree().get_first_node_in_group("player") as Node2D
  if player == null:
    return

  var enemies = get_tree().get_nodes_in_group("enemy")
  
  enemies = enemies.filter(func(enemy: Node2D):
      return enemy.global_position.distance_squared_to(player.global_position) < pow(base_sword_rage, 2)
  )

  if enemies.size() == 0:
    return
  
  enemies.sort_custom(
    func(a: Node2D, b: Node2D):
      var a_distance = a.global_position.distance_squared_to(player.global_position)
      var b_distance = b.global_position.distance_squared_to(player.global_position)
      return a_distance < b_distance
  )

  var sword_instance = sword_ability_scene.instantiate() as Node2D

  # 获取前景节点，以添加能力的实例
  var foreground = get_tree().get_first_node_in_group("foreground_layer")
  if foreground == null:
    return
  foreground.add_child(sword_instance)
  var enemy_direction_vector = enemies[0].global_position - player.global_position

  sword_instance.global_position = player.global_position + enemy_direction_vector - enemy_direction_vector.normalized() * 20
  sword_instance.rotation = enemy_direction_vector.angle()

  # 配置攻击的伤害
  sword_instance.hitbox_component.damage = current_damage

# 技能升级
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
  if upgrade.id == "sword_rate":
    current_wait_time = base_wait_time * pow((1 - percent_reduction), current_upgrades["sword_rate"]["quantity"])
    $Timer.wait_time = current_wait_time
    $Timer.start() # 重置循环时间
    print("sword_rate已升级到", current_wait_time)
  elif upgrade.id == "sword_damage":
    current_damage += additional_damage
    print("sword_damage已升级到", current_damage)
  else:
    return
