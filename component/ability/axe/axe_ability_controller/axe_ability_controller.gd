extends Node

@export var attack_rage: float = 150

@export var base_wait_time: float = 3

@export var axe_ability_scene: PackedScene

func _ready() -> void:
  # get_node("Timer") # 找到子节点
  $Timer.wait_time = base_wait_time
  $Timer.timeout.connect(on_timer_timeout)


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
