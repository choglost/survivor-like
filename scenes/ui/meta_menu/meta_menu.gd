extends CanvasLayer

signal back_pressed

@export var upgrades: Array[MetaUpgrade] = []

@onready var grid_container: GridContainer = $%GridContainer
@onready var currency_label: Label = $%CurrencyLabel
@onready var back_button: Button = $%BackButton

var meta_upgrade_card_scene = preload("res://scenes/ui/meta_menu/meta_upgrade_card/meta_upgrade_card.tscn")
var cards: Array[Node] = []

func _ready():
  back_button.pressed.connect(on_back_button_pressed)
  MetaProgression.currency_changed.connect(on_currency_changed)
  MetaProgression.meta_upgrade_purchased.connect(on_meta_upgrade_purchased)
  update_currency_label()

  for upgrade in upgrades:
    var meta_upgrade_card_instance = meta_upgrade_card_scene.instantiate()
    grid_container.add_child(meta_upgrade_card_instance)
    meta_upgrade_card_instance.set_meta_upgrade_card(upgrade)
    cards.append(meta_upgrade_card_instance)

func update_currency_label() -> void:
  currency_label.text = str(MetaProgression.get_currency())

func refresh_cards() -> void:
  for card in cards:
    card.refresh()

func on_currency_changed(_currency: int) -> void:
  update_currency_label()
  refresh_cards()

func on_meta_upgrade_purchased(_upgrade: MetaUpgrade, _current_level: int) -> void:
  update_currency_label()
  refresh_cards()

func on_back_button_pressed() -> void:
  back_pressed.emit()
