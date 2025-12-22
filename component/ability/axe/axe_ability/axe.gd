extends Node2D

class_name AxeAbility

@export var axe_attack_radius: float = 70.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var base_rotation = Vector2.RIGHT

func _ready() -> void:
  base_rotation = Vector2.RIGHT.rotated(randf_range(0, PI * 2))
  var tween = create_tween()
  tween.tween_method(axe_rotate, 0.0, 4.0, 2.5)
  tween.tween_callback(queue_free)

func axe_rotate(axe_rotation: float) -> void:
  var percent = axe_rotation / 2.0
  var current_radius = axe_attack_radius * percent
  var current_direction = base_rotation.rotated(axe_rotation * PI * 2)

  var player = get_tree().get_first_node_in_group("player") as Node2D
  if player == null:
    return
  global_position = player.global_position + (current_direction * current_radius)
