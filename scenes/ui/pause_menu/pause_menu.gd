extends CanvasLayer

var options_menu_scene = preload("res://scenes/ui/options_menu/options_menu.tscn")

func _ready() -> void:
  get_tree().paused = true
  $%ResumeButton.pressed.connect(on_resume_button_pressed)
  $%OptionsButton.pressed.connect(on_options_button_pressed)
  $%MainMenuButton.pressed.connect(on_mainmenu_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
  # 再次按下暂停键也恢复
  if event.is_action_pressed("pause"):
    pause_closed()
    get_tree().root.set_input_as_handled()

func on_resume_button_pressed() -> void:
  pause_closed()

func on_options_button_pressed() -> void:
  var options_menu_instance = options_menu_scene.instantiate()
  add_child(options_menu_instance)
  options_menu_instance.back_pressed.connect(on_options_back_pressed.bind(options_menu_instance))

func pause_closed():
  get_tree().paused = false
  queue_free()

func on_options_back_pressed(options_menu: Node):
  options_menu.queue_free()

func on_mainmenu_button_pressed() -> void:
  get_tree().paused = false
  get_tree().change_scene_to_file("res://scenes/ui/main_menu/main_menu.tscn")
