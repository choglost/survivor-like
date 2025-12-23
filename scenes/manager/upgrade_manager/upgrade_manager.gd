extends Node

@export var upgrade_pool: Array[AbilityUpgrade]
@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {} # 字典，存放技能id和当前等级

# var upgrade_pool: WeightedTable = WeightedTable.new()

# 预加载升级变量
# var


func _ready() -> void:
  experience_manager.level_up.connect(on_level_up)

# 升级时展示选择技能面板
func on_level_up(level: int) -> void:
  var upgrade_screen_instance = upgrade_screen_scene.instantiate()
  add_child(upgrade_screen_instance)

  var chosen_upgrades = pick_upgrades()
  upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade], current_upgrades)
  upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)

# 选中技能后，应用升级
func on_upgrade_selected(upgrade: AbilityUpgrade) -> void:
  apply_upgrade(upgrade)

# 升级某个技能
func apply_upgrade(upgrade: AbilityUpgrade) -> void:
  var has_upgrade = current_upgrades.has(upgrade.id)
  if !has_upgrade:
    current_upgrades[upgrade.id] = {
      "resource": upgrade.id,
      "quantity": 1,
    }
  else:
    current_upgrades[upgrade.id]["quantity"] += 1
  
  # 当技能升级到最大等级时，从升级池中移除
  if upgrade.max_quantity > 0:
    var current_quantity = current_upgrades[upgrade.id]["quantity"]
    if current_quantity == upgrade.max_quantity:
      upgrade_pool = upgrade_pool.filter(
        func(pool_upgrade) -> bool:
          return pool_upgrade.id != upgrade.id
      )

  GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades) # 触发技能升级添加的信号，把效果应用到游戏

  # print(current_upgrades)


func pick_upgrades() -> Array[AbilityUpgrade]:
  var chosen_upgrades: Array[AbilityUpgrade] = []
  var filtered_upgrades = upgrade_pool.duplicate()
  
  for i in 2:
    if filtered_upgrades.size() == 0:
      break
    var chosen_upgrade = filtered_upgrades.pick_random() as AbilityUpgrade
    chosen_upgrades.append(chosen_upgrade)
    filtered_upgrades = filtered_upgrades.filter(
      func(upgrade) -> bool:
        return upgrade.id != chosen_upgrade.id
    )
    
  return chosen_upgrades