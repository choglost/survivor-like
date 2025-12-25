extends Area2D

class_name HurtboxComponent


signal get_hurt

@export var health_component: Node
## 受伤无敌时间
@export var hurt_interval: float = 0.1


@onready var damage_interval_timer: Timer = $DamageIntervalTimer

var hitbox_component: Area2D

var floating_text_scene = preload("res://scenes/ui/floating_text/floating_text.tscn")

var can_hurt: bool = true

func _ready():
  area_entered.connect(on_area_entered)
  damage_interval_timer.timeout.connect(set_can_hurt)
  damage_interval_timer.wait_time = hurt_interval

func on_area_entered(other_area: Area2D):
  if not other_area is HitboxComponent:
    return
  hitbox_component = other_area
  check_damage()

func check_damage():
  if health_component == null:
    return
  if hitbox_component == null:
    return
  if can_hurt == false:
    return
  
  # 发出播放伤害音效的信号
  get_hurt.emit()
  # 造成伤害
  health_component.take_damage(hitbox_component.damage)

  # 设置无敌时间
  can_hurt = false
  damage_interval_timer.start()

  # 展示伤害数字
  var floating_text_instance = floating_text_scene.instantiate() as Node2D
  get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text_instance)
  floating_text_instance.global_position = global_position + Vector2.UP * 10
  floating_text_instance.start(hitbox_component.damage)

  
func set_can_hurt():
  can_hurt = true