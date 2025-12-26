extends PanelContainer

signal selected

@onready var name_label: Label = $%NameLabel
@onready var level_label: Label = $%LevelLabel
@onready var description_label: Label = $%DescriptionLabel
@onready var animation_player: AnimationPlayer = $%AnimationPlayer
@onready var progress_bar: ProgressBar = $%ProgressBar

var meta_upgrade: MetaUpgrade

func _ready() -> void:
  gui_input.connect(on_gui_input)
  $%PurchaseButton.pressed.connect(on_pruchase_pressed)

func set_meta_upgrade_card(upgrade: MetaUpgrade):
  meta_upgrade = upgrade
  name_label.text = upgrade.name
  description_label.text = upgrade.description
  # level_label.text = str(current_level) + "/" + str(upgrade.max_quantity)
  progress_bar.value = min(MetaProgression.save_data["currency"] / upgrade.cost, 1)
  progress_bar.disabled = progress_bar.value < 1

func on_gui_input(event: InputEvent):
  if event.is_action_pressed("left_click"):
    animation_player.play("selected")

    await animation_player.animation_finished
    selected.emit()

# func play_in(delay: float = 0):
#   modulate = Color.TRANSPARENT
#   await get_tree().create_timer(delay).timeout # 异步 等待一段时间
#   # modulate = Color.WHITE # 放在动画里 已解决动画第一帧scale还不是0时就变不透明的问题
#   animation_player.play("in")

func on_pruchase_pressed():
  MetaProgression.add_meta_upgrade(meta_upgrade)

  # 更新等级
