extends Node

signal experience_gained(amount: int)

func emit_experience_gained(amount: int):
	experience_gained.emit(amount)