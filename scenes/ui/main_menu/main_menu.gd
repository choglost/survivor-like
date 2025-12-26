extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu/options_menu.tscn")


func _ready() -> void:
  $%PlayButton.pressed.connect(on_play_pressed)
  $%OptionsButton.pressed.connect(on_options_pressed)
  $%QuitButton.pressed.connect(on_quit_pressed)
  $%MetaButton.pressed.connect(on_meta_pressed)

func on_play_pressed() -> void:
  get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func on_options_pressed() -> void:
  var options_menu_instance = options_scene.instantiate()
  add_child(options_menu_instance)
  options_menu_instance.back_pressed.connect(on_options_closed.bind(options_menu_instance))

func on_meta_pressed() -> void:
  var options_menu_instance = options_scene.instantiate()
  add_child(options_menu_instance)
  options_menu_instance.back_pressed.connect(on_options_closed.bind(options_menu_instance))


func on_quit_pressed() -> void:
  get_tree().quit()

func on_options_closed(options_instance: Node) -> void:
  options_instance.queue_free()
