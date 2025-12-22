extends CharacterBody2D

@export var speed = 200.0

const ACCELERATION = 30

# 获取子节点
@onready var health_component = $HealthComponent # 供main.gd访问
@onready var ability_manager = $AbilityManager
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals

func _ready() -> void:
  GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
  # health_component.health_changed.connect(on_health_changed)

func _process(delta: float) -> void:
  var movement_vector = get_movement_vector()
  var direction = movement_vector.normalized() # 标准化
  var target_velocity = direction * speed

  velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION))
  move_and_slide()

  # 播放动画
  if velocity.length() > 0.1:
    animation_player.play("walk")
  else:
    animation_player.play("RESET")

  var move_sign = sign(movement_vector.x)
  if move_sign != 0:
    visuals.scale = Vector2(move_sign, 1)

# 获取移动向量
func get_movement_vector() -> Vector2:
  var movement_vector = Vector2.ZERO
  movement_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
  movement_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
  return movement_vector

# func on_health_changed(health: int) -> void:

# 增加新能力
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
  if not ability_upgrade is Ability:
    return

  ability_manager.add_child(ability_upgrade.ability_controller_scene.instantiate())