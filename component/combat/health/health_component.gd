extends Node

class_name HealthComponent

signal health_changed
signal died

@export var max_health: float = 10
@export var health_bar: PackedScene

var current_health: float
var health_bar_instance: ProgressBar

func _ready() -> void:
  current_health = max_health
  if not health_bar == null:
    health_bar_instance = health_bar.instantiate()
    get_parent().add_child.call_deferred(health_bar_instance)

    health_changed.connect(on_health_changed)
  # if not health_bar == null:
    # health_bar_instance.visible = true


func _process(delta: float) -> void:
  pass

func take_damage(damage: float) -> void:
  # print(owner.name + " 受" + str(damage) + "点伤害")
  current_health = max(current_health - damage, 0)
  health_changed.emit()
  if current_health <= 0:
    died.emit()
    # Callable(check_death).call_deferred() # 延迟调用，防止掉落物还没生成，物体就已销毁

# func check_death() -> void:
#   # print(get_parent().name + " 死了")
#   get_parent().queue_free()

func get_health_percent() -> float:
  if current_health <= 0:
    return 0
  return min(current_health / max_health, 1)

func on_health_changed() -> void:
  if not health_bar == null:
    health_bar_instance.value = get_health_percent()
