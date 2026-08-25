extends PanelContainer

@onready var name_label: Label = $%NameLabel
@onready var level_label: Label = $%LevelLabel
@onready var description_label: Label = $%DescriptionLabel
@onready var progress_bar: ProgressBar = $%ProgressBar
@onready var purchase_button: Button = $%PurchaseButton
@onready var cost_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label

var meta_upgrade: MetaUpgrade

func _ready() -> void:
  purchase_button.pressed.connect(on_purchase_pressed)

func set_meta_upgrade_card(upgrade: MetaUpgrade) -> void:
  meta_upgrade = upgrade
  refresh()

func refresh() -> void:
  if meta_upgrade == null:
    return

  var current_level = MetaProgression.get_upgrade_level(meta_upgrade.id)
  var cost = MetaProgression.get_upgrade_cost(meta_upgrade)
  var currency = MetaProgression.get_currency()
  var is_maxed = MetaProgression.is_upgrade_maxed(meta_upgrade)

  name_label.text = meta_upgrade.title
  description_label.text = meta_upgrade.description
  level_label.visible = true
  level_label.text = str(current_level) + "/" + str(meta_upgrade.max_level)
  cost_label.text = str(currency) + "/" + str(cost)
  progress_bar.value = 1.0 if cost <= 0 else min(float(currency) / cost, 1.0)
  purchase_button.disabled = !MetaProgression.can_purchase(meta_upgrade)
  purchase_button.text = "已满级" if is_maxed else "购买"

func on_purchase_pressed() -> void:
  if MetaProgression.purchase_upgrade(meta_upgrade):
    refresh()
