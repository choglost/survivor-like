extends CharacterBody2D


const SPEED = 70

@onready var health_component: Node = $HealthComponent

func _process(delta: float) -> void:
  var direction = get_direction_to_player()
  velocity = direction * SPEED
  move_and_slide()



func get_direction_to_player():
  var player_node = get_tree().get_first_node_in_group("player")
  if player_node != null:
    return (player_node.global_position - global_position).normalized()
  return Vector2.ZERO
