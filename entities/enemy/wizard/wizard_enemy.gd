extends CharacterBody2D

@onready var visuals: Node = $Visuals
@onready var movement_component: Node = $MovementComponent

var is_moving: bool = false

func _process(delta: float) -> void:
  if is_moving:
    movement_component.accelerate_to_player()
  else:
    movement_component.decelerate()
  
  movement_component.move(self)

  var move_sign = sign(velocity.x)
  if move_sign != 0:
    visuals.scale = Vector2(move_sign, 1)

func set_is_moving(value: bool) -> void:
  is_moving = value