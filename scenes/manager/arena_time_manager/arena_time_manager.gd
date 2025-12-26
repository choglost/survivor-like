extends Node

signal arena_difficulty_increased(arena_difficulty: int)

## 难度递增时间
@export var difficulty_interval = 5
## 游戏结束屏幕
@export var end_screen: PackedScene

@onready var timer = $Timer

var arena_difficulty = 0


func _ready() -> void:
  timer.timeout.connect(on_timer_timeout)

func _process(delta: float) -> void:
  var next_time_target = timer.wait_time - ((arena_difficulty + 1) * difficulty_interval)
  if timer.time_left < next_time_target:
    arena_difficulty += 1
    arena_difficulty_increased.emit(arena_difficulty)

func get_time_elapsed() -> float:
  return timer.wait_time - timer.time_left

func on_timer_timeout() -> void:
  var end_screen_instance = end_screen.instantiate()
  add_child(end_screen_instance)
  end_screen_instance.play_end_audio()
  MetaProgression.save_file()