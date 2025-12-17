extends CanvasLayer

@export var arena_time_manager: Node
@onready var label: Label = $MarginContainer/Label
# $%Label

func _process(delta: float) -> void:
	if arena_time_manager == null:
		return
	var time_elapsed = arena_time_manager.get_time_elapsed()
	label.text = sec2str(time_elapsed)

func sec2str(time: float) -> String:
	var minutes = floor(time / 60)
	var seconds = floor(time - minutes * 60)
	return ("%02d"%minutes) + ":" + ("%02d"%seconds)
