extends Node

class_name HealthComponent

signal died

@export var max_health: float = 10

var current_health: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(damage: float) -> void:
	current_health = max(current_health - damage, 0)
	if current_health <= 0:
		died.emit()
		Callable(check_death).call_deferred() # 延迟调用，防止掉落物还没生成，物体就已销毁

func check_death() -> void:	
		owner.queue_free()