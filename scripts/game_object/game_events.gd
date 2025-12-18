extends Node

signal experience_gained(amount: int)
signal ability_upgrade_added(upgrade: AbilityUpgrade,current_upgrades: Dictionary)

func emit_experience_gained(amount: int):
	experience_gained.emit(amount)

func emit_ability_upgrade_added(upgrade: AbilityUpgrade,current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade,current_upgrades)