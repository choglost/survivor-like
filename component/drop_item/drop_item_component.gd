extends Node

@export_range(0, 1) var drop_percent: float = 1
@export var drop_item: PackedScene
@export var health_component: Node

func _ready() -> void:
  health_component.died.connect(on_died)

func on_died() -> void:
  if randf() > drop_percent:
    return

  if drop_item == null:
    return

  if not owner is Node2D:
    return
  
  var drop_item_instance = drop_item.instantiate() as Node2D
  var drop_item_position = owner.global_position
  var entities_layer = get_tree().get_first_node_in_group("entities_layer")
  entities_layer.add_child(drop_item_instance)
  
  # drop_item_instance.global_position = drop_item_position
  # 解决报错
  drop_item_instance.call_deferred("set_global_position", drop_item_position)