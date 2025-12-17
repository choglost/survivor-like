extends Node

@export_range(0, 1) var drop_percent: float = 0.5
@export var drop_item: PackedScene
@export var health_component: Node

func _ready() -> void:
  health_component.died.connect(on_died)

func on_died() -> void:
  if randf() > drop_percent:
    return

  if drop_item==null:
    return

  if not owner is Node2D:
    return
  
  var drop_item_instance = drop_item.instantiate() as Node2D
  var drop_item_position = owner.global_position
  owner.get_parent().add_child(drop_item_instance)
  drop_item_instance.global_position = drop_item_position