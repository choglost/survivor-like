extends CharacterBody2D

@onready var visuals: Node = $Visuals
@onready var movement_component: Node = $MovementComponent

func _process(delta: float) -> void:
  movement_component.accelerate_to_player()
  movement_component.move(self)

  var move_sign = sign(velocity.x)
  if move_sign != 0:
    visuals.scale = Vector2(move_sign, 1)
