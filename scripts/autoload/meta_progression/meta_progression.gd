extends Node

signal currency_changed(currency: int)
signal meta_upgrade_purchased(upgrade: MetaUpgrade, current_level: int)

const SAVE_FILE_PATH = "user://game.save"

var save_data: Dictionary = {
  "currency": 0,
  "meta_upgrades": {},
}

func _ready():
  load_file()
  ensure_save_data_shape()
  GameEvents.coin_gained.connect(on_currency_collected)

func load_file():
  if !FileAccess.file_exists(SAVE_FILE_PATH):
    return
  var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
  if file == null:
    return

  var loaded_data = file.get_var()
  if loaded_data is Dictionary:
    save_data = loaded_data

func save_file():
  var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
  if file == null:
    return
  file.store_var(save_data)


func on_currency_collected(number: int):
  save_data["currency"] += number
  save_file()
  currency_changed.emit(get_currency())

func ensure_save_data_shape() -> void:
  if !save_data.has("currency") || !(save_data["currency"] is int):
    save_data["currency"] = 0
  if !save_data.has("meta_upgrades") || !(save_data["meta_upgrades"] is Dictionary):
    save_data["meta_upgrades"] = {}

func get_currency() -> int:
  return int(save_data.get("currency", 0))

func get_upgrade_level(upgrade_id: String) -> int:
  var meta_upgrades = save_data.get("meta_upgrades", {})
  if !(meta_upgrades is Dictionary):
    return 0
  if !meta_upgrades.has(upgrade_id):
    return 0

  var upgrade_data = meta_upgrades[upgrade_id]
  if !(upgrade_data is Dictionary):
    return 0

  return int(upgrade_data.get("quantity", 0))

func get_upgrade_cost(upgrade: MetaUpgrade) -> int:
  return upgrade.cost

func is_upgrade_maxed(upgrade: MetaUpgrade) -> bool:
  if upgrade.max_level <= 0:
    return false
  return get_upgrade_level(upgrade.id) >= upgrade.max_level

func can_purchase(upgrade: MetaUpgrade) -> bool:
  if upgrade == null:
    return false
  if is_upgrade_maxed(upgrade):
    return false
  return get_currency() >= get_upgrade_cost(upgrade)

func purchase_upgrade(upgrade: MetaUpgrade) -> bool:
  if !can_purchase(upgrade):
    return false

  if !save_data["meta_upgrades"].has(upgrade.id):
    save_data["meta_upgrades"][upgrade.id] = {
      "quantity": 0
    }

  save_data["meta_upgrades"][upgrade.id]["quantity"] += 1
  save_data["currency"] -= get_upgrade_cost(upgrade)

  save_file()
  currency_changed.emit(get_currency())
  meta_upgrade_purchased.emit(upgrade, get_upgrade_level(upgrade.id))
  return true

func add_meta_upgrade(upgrade: MetaUpgrade) -> bool:
  return purchase_upgrade(upgrade)
