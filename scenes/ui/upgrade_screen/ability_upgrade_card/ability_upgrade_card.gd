extends PanelContainer

signal selected

@onready var name_label: Label = $%NameLabel
@onready var level_label: Label = $%LevelLabel
@onready var description_label: Label = $%DescriptionLabel
@onready var animation_player: AnimationPlayer = $%AnimationPlayer

var disabled = false # 防止多次点击

func _ready() -> void:
  gui_input.connect(on_gui_input)
  mouse_entered.connect(on_mouse_entered)

func set_ability_upgrade_card(upgrade: AbilityUpgrade, current_level: int):
  name_label.text = upgrade.name
  description_label.text = upgrade.description
  level_label.text = str(current_level) + "/" + str(upgrade.max_quantity)

func on_gui_input(event: InputEvent):
  if disabled:
    return

  if event.is_action_pressed("left_click"):
    disabled = true
    animation_player.play("selected")

    for other_card in get_tree().get_nodes_in_group("upgrade_card"):
      if other_card != self:
        other_card.animation_player.play("discard")
        

    await animation_player.animation_finished
    selected.emit()

func play_in(delay: float = 0):
  modulate = Color.TRANSPARENT
  await get_tree().create_timer(delay).timeout # 异步 等待一段时间
  # modulate = Color.WHITE # 放在动画里 已解决动画第一帧scale还不是0时就变不透明的问题
  animation_player.play("in")

func on_mouse_entered():
  if disabled:
    return
  $HoverAnimationPlayer.play("hover")

# func play_discard():
#   animation_player.play("discard")
