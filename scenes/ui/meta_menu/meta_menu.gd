extends CanvasLayer

signal back_pressed

@export var upgarades: Array[MetaUpgrade] = []

@onready var grid_container: GridContainer = $%GridContainer

var meta_upgreade_card_scene = preload("res://scenes/ui/meta_menu/meta_upgrade_card/meta_upgrade_card.tscn")

func _ready():
  for upgrade in upgarades:
    var meta_upgrade_card_instance = meta_upgreade_card_scene.instantiate()
    meta_upgrade_card_instance.set_upgrade(upgrade)
    grid_container.add_child(meta_upgrade_card_instance)
