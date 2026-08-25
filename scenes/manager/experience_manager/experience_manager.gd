extends Node

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)

const BASE_TARGET_EXPERIENCE = 5
const EXP_INCREMENT = 3
const EXPERIENCE_GAIN_META_UPGRADE_ID = "experience_gain"
const EXPERIENCE_REQUIREMENT_REDUCTION = 0.05

var current_experience = 0.0
var current_level = 1
var target_experience = BASE_TARGET_EXPERIENCE
var target_experience_multiplier = 1.0

func _ready():
  target_experience_multiplier = get_target_experience_multiplier()
  target_experience = get_target_experience_for_level(current_level)
  GameEvents.experience_gained.connect(on_experience_gained)

func on_experience_gained(amount: float):
  current_experience = min(current_experience + amount, target_experience)
  experience_updated.emit(current_experience, target_experience)

  if current_experience >= target_experience:
    do_level_up()

func do_level_up():
  current_level += 1
  current_experience = 0
  target_experience = get_target_experience_for_level(current_level)
  experience_updated.emit(current_experience, target_experience)
  level_up.emit(current_level)
  print("Current level:", str(current_level))

func get_target_experience_multiplier() -> float:
  var meta_level = MetaProgression.get_upgrade_level(EXPERIENCE_GAIN_META_UPGRADE_ID)
  return max(0.1, 1.0 - meta_level * EXPERIENCE_REQUIREMENT_REDUCTION)

func get_target_experience_for_level(level: int) -> float:
  var base_target = BASE_TARGET_EXPERIENCE + (level - 1) * EXP_INCREMENT
  return max(1.0, base_target * target_experience_multiplier)
