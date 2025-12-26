extends CanvasLayer

signal back_pressed


@onready var window_button: Button = $%WindowButton
@onready var sfx_slider: Slider = $%SfxSlider
@onready var music_slider: Slider = $%MusicSlider
@onready var back_button: Button = $%BackButton

func _ready() -> void:
  back_button.pressed.connect(on_back_button_pressed)
  window_button.pressed.connect(on_window_button_pressed)
  music_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
  sfx_slider.value_changed.connect(on_audio_slider_changed.bind("sfx"))
  
  update_display()

func on_window_button_pressed() -> void:
  var mode = DisplayServer.window_get_mode()
  if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
  else:
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
  
  update_display()

func update_display():
  window_button.text = "窗口" # windowed
  if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
    window_button.text = "全屏" # fullscreen
  
  sfx_slider.value = get_bus_volume_percent("sfx")
  music_slider.value = get_bus_volume_percent("music")

# 获取音量
func get_bus_volume_percent(bus_name: String):
  var bus_index = AudioServer.get_bus_index(bus_name)
  var volumn_db = AudioServer.get_bus_volume_db(bus_index)
  return db_to_linear(volumn_db)

# 设置音量
func set_bus_volume_percent(bus_name: String, percent: float):
  var bus_index = AudioServer.get_bus_index(bus_name)
  var volumn_db = linear_to_db(percent)
  AudioServer.set_bus_volume_db(bus_index, volumn_db)

func on_audio_slider_changed(value: float, bus_name: String) -> void:
  set_bus_volume_percent(bus_name, value)

func on_back_button_pressed() -> void:
  # get_tree().change_scene_to_file("res://scenes/ui/main_menu/main_menu.tscn")
  back_pressed.emit()
