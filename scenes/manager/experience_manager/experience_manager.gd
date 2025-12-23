extends Node

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)

const EXP_INCREMENT = 1

var current_experience = 0
var current_level = 1

var target_experience = 5

func _ready():
	GameEvents.experience_gained.connect(on_experience_gained) # 监听并处理信号

# 获得经验
func on_experience_gained(amount: float):
	increase_experience(amount)

func increase_experience(amount: float):
	current_experience = min(current_experience + amount, target_experience)
	# print("Current experience:",str(current_experience))
	experience_updated.emit(current_experience, target_experience)

	if current_experience >= target_experience:
		do_level_up()

func do_level_up():
	current_level += 1
	current_experience = 0
	target_experience += EXP_INCREMENT
	experience_updated.emit(current_experience, target_experience)
	level_up.emit(current_level)
	# print("Level up!")
	print("Current level:", str(current_level))
	# print("Experience to level up:",str(target_experience))

