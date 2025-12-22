extends CanvasLayer

signal upgrade_selected(upgrade: AbilityUpgrade) # 信号，监测技能升级被选中

@export var upgrade_card_scene: PackedScene

@onready var card_container: HBoxContainer = $%CardHBoxContainer

func _ready() -> void:
  get_tree().paused = true

# 展示若干个“技能升级卡片”子节点
func set_ability_upgrades(upgrades: Array[AbilityUpgrade], current_upgrades: Dictionary):
  for upgrade in upgrades:
    var card_instance = upgrade_card_scene.instantiate()
    card_container.add_child(card_instance)

    var current_level = 0
    if current_upgrades.has(upgrade.id):
      current_level = current_upgrades[upgrade.id]["quantity"]
    card_instance.set_ability_upgrade_card(upgrade, current_level)
    card_instance.selected.connect(on_upgrade_selected.bind(upgrade))

# 点击“技能升级卡片”子节点后销毁本节点
func on_upgrade_selected(upgrade: AbilityUpgrade):
  upgrade_selected.emit(upgrade)
  get_tree().paused = false
  queue_free()
