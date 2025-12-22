extends Node2D

func _ready() -> void:
  $Area2D.area_entered.connect(on_area_entered)

func _process(delta: float) -> void:
  pass

func on_area_entered(area: Area2D) -> void:
  GameEvents.emit_experience_gained(1) # 触发信号
  queue_free()