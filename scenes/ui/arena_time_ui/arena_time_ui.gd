extends CanvasLayer

@export var arena_time_manager: Node
@onready var label: Label = $MarginContainer/Label
# $%Label

func _process(delta: float) -> void:
  if arena_time_manager == null:
    return
  # 已经过去的时间
  var time_elapsed = arena_time_manager.get_time_elapsed()
  # 剩下的时间
  var time_left = arena_time_manager.timer.time_left
  
  label.text = sec2str(time_left)

func sec2str(time: float) -> String:
  var minutes = floor(time / 60)
  var seconds = floor(time - minutes * 60)
  return ("%02d"%minutes) + ":" + ("%02d"%seconds)
