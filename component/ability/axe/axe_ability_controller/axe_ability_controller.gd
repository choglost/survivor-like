extends Node

@export var attack_rage: float = 150

@export var base_wait_time: float = 3

@export var axe_ability_scene: PackedScene

var base_damage: float = 10
var current_damage: float = base_damage
var additional_damage: float = 2

func _ready() -> void:
  # get_node("Timer") # 找到子节点
  $Timer.wait_time = base_wait_time
  $Timer.timeout.connect(on_timer_timeout)

  GameEvents.ability_upgrade_added.connect(on_ability_upgraded) # 连接全局升级信号


func on_timer_timeout() -> void:
  # 获取玩家节点
  var player = get_tree().get_first_node_in_group("player") as Node2D
  if player == null:
    return

  # 获取前景节点，以添加能力的实例
  var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
  if foreground == null:
    return
  
  var axe_instance = axe_ability_scene.instantiate() as Node2D

  foreground.add_child(axe_instance)
  axe_instance.global_position = player.global_position

  # 配置攻击的伤害
  axe_instance.hitbox_component.damage = current_damage


func on_ability_upgraded(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
  if upgrade.id == "axe_damage":
    current_damage += additional_damage
    print("Axe damage upgraded to: ", current_damage)
  else:
    return