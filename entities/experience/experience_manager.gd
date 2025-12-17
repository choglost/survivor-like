extends Node

var current_experience = 0

func _ready():
	current_experience = 0
	GameEvents.experience_gained.connect(on_experience_gained) # 监听并处理信号

func on_experience_gained(amount:float):
	increase_experience(amount)

func increase_experience(amount:float):
	current_experience += amount
	print("Current experience:",str(current_experience))