extends Area2D

class_name HurtboxComponent

# 受伤无敌时间
@export var hurt_interval: float = 0.1

@export var health_component: Node

@onready var damage_interval_timer: Timer = $DamageIntervalTimer

var hitbox_component: Area2D

func _ready():
  area_entered.connect(on_area_entered)
  damage_interval_timer.timeout.connect(check_damage)
  damage_interval_timer.wait_time = hurt_interval

func on_area_entered(other_area: Area2D):
  if not other_area is HitboxComponent:
    return
  hitbox_component = other_area
  check_damage()

func check_damage():
  if health_component == null:
    return
  if not damage_interval_timer.is_stopped():
    return
  if hitbox_component == null:
    return
  health_component.take_damage(hitbox_component.damage)
  damage_interval_timer.start()
