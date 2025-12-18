extends CharacterBody2D

@export var speed = 200.0

const ACCELERATION = 30

# 供main.gd访问
@onready var health_component = $HealthComponent

func _ready() -> void:
  pass
  # health_component.health_changed.connect(on_health_changed)
func _process(delta: float) -> void:
  var movement_vector = get_movement_vector()
  var direction = movement_vector.normalized() # 标准化
  var target_velocity = direction * speed

  velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION))
  move_and_slide()

func get_movement_vector() -> Vector2:
  var movement_vector = Vector2.ZERO
  movement_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
  movement_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
  return movement_vector

# func on_health_changed(health: int) -> void:
