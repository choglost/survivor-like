extends PanelContainer

signal selected

@onready var name_label: Label = $%NameLabel
@onready var level_label: Label = $%LevelLabel
@onready var description_label: Label = $%DescriptionLabel

func _ready() -> void:
  gui_input.connect(on_gui_input)

func set_ability_upgrade_card(upgrade: AbilityUpgrade, current_level: int):
  name_label.text = upgrade.name
  description_label.text = upgrade.description
  level_label.text = str(current_level) + "/" + str(upgrade.max_quantity)

func on_gui_input(event: InputEvent):
  if event.is_action_pressed("left_click"):
    selected.emit()
