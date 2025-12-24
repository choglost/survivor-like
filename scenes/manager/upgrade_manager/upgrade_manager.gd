extends Node


@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

@export var show_card_num: int = 3

# @export var upgrade_pool: Array[AbilityUpgrade]
var upgrade_pool = WeightedTable.new()

var current_upgrades = {} # 字典，存放技能id和当前等级
# 预加载升级资源
var get_rotate_axe = preload("res://resources/upgrades/get_rotate_axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")


func _ready() -> void:
  upgrade_pool.add_item(get_rotate_axe, 10)
  upgrade_pool.add_item(upgrade_sword_rate, 10)
  upgrade_pool.add_item(upgrade_sword_damage, 10)
  upgrade_pool.add_item(upgrade_player_speed, 5)

  experience_manager.level_up.connect(on_level_up)

# 升级时展示选择技能面板
func on_level_up(level: int) -> void:
  var upgrade_screen_instance = upgrade_screen_scene.instantiate()
  add_child(upgrade_screen_instance)

  var upgrades_to_show = pick_upgrades()
  upgrade_screen_instance.set_ability_upgrades(upgrades_to_show as Array[AbilityUpgrade], current_upgrades)
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
    
  update_upgrade_pool(upgrade) # 更新升级池

  # 触发技能升级添加的信号，把效果应用到游戏
  GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)

  # print(current_upgrades)


func pick_upgrades() -> Array[AbilityUpgrade]:
  var upgrades_to_show: Array[AbilityUpgrade] = []

  ## 旧的过滤方法
  # var filtered_upgrades = upgrade_pool.duplicate()  
  # for i in 2:
  #   if filtered_upgrades.size() == 0:
  #     break
  #   var chosen_upgrade = filtered_upgrades.pick_random() as AbilityUpgrade
  #   chosen_upgrades.append(chosen_upgrade)
  #   filtered_upgrades = filtered_upgrades.filter(
  #     func(upgrade) -> bool:
  #       return upgrade.id != chosen_upgrade.id
  #   )

  for i in show_card_num:
    if upgrade_pool.items.size() == 0:
      break
    var upgrade_to_show = upgrade_pool.pick_item(upgrades_to_show) as AbilityUpgrade
    upgrades_to_show.append(upgrade_to_show)
    
  return upgrades_to_show

# 升级技能时，更新升级池，从而实现技能等级上限限制、技能树等功能
func update_upgrade_pool(upgrade: AbilityUpgrade) -> void:
  # 当技能升级到最大等级时，从升级池中移除
  if upgrade.max_quantity > 0:
    var current_quantity = current_upgrades[upgrade.id]["quantity"]
    if current_quantity == upgrade.max_quantity:
      upgrade_pool.remove_item(upgrade)
  # 当升级了“get_rotate_axe”时，加入技能“upgrade_axe_damage”
  if upgrade.id == get_rotate_axe.id:
    upgrade_pool.add_item(upgrade_axe_damage, 10)
