extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $Area2D.area_entered.connect(on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func on_area_entered(area: Area2D) -> void:
  GameEvents.emit_experience_gained(1) # 触发信号
  queue_free()