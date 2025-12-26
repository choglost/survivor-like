extends Node

const SAVE_FILE_PATH = "user://game.save"

var save_data: Dictionary = {
  "currency": 0,
  "meta_upgrades": {},
}

func _ready():
  load_file()
  GameEvents.coin_gained.connect(on_currency_collected)

func load_file():
  if !FileAccess.file_exists(SAVE_FILE_PATH):
    return
  var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
  save_data = file.get_var()
  print(save_data)

func save_file():
  print(save_data)
  var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
  file.store_var(save_data)


func on_currency_collected(number: int):
  save_data["currency"] += number
  save_file()

func add_meta_upgrade(upgrade: MetaUpgrade):
  if !save_data["meta_upgrades"].has(upgrade.id):
    save_data["meta_upgrades"][upgrade.id] = {
      "quantity": 0
    }
  else:
    save_data["meta_upgrades"][upgrade.id]["quantity"] += 1

  save_data["currency"] -= upgrade.cost
  save_file()
