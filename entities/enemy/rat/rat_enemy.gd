extends CharacterBody2D


# @onready var health_component: Node = $HealthComponent
@onready var visuals: Node = $Visuals
@onready var movement_component: Node = $MovementComponent


func _ready() -> void:
  # $HurtboxComponent.get_hurt.connect(on_get_hurt)
  $HealthComponent.died.connect(on_died)
  $HealthComponent.health_changed.connect(on_health_changed)

func _process(delta: float) -> void:
  movement_component.accelerate_to_player()
  movement_component.move(self)

  var move_sign = sign(velocity.x)
  if move_sign != 0:
    visuals.scale = Vector2(move_sign, 1)


# func get_direction_to_player() -> Vector2:
#   var player_node = get_tree().get_first_node_in_group("player")
#   if player_node != null:
#     return (player_node.global_position - global_position).normalized()
#   return Vector2.ZERO

func on_health_changed() -> void:
  $RandomAudioPlayerComponent.play_random_audio()
  

func on_died() -> void:
  await $RandomAudioPlayerComponent.finished
  queue_free()
