extends Node2D

@onready var collosion_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D


func _ready() -> void:
  $Area2D.area_entered.connect(on_area_entered)

func _process(delta: float) -> void:
  pass

func tween_collected(percent: float, start_postion: Vector2) -> void:
  var player = get_tree().get_first_node_in_group("player")
  if player == null:
    return
  
  global_position = start_postion.lerp(player.global_position, percent)

  var direction_from_start = player.global_position - start_postion
  var target_rotation = direction_from_start.angle() + PI / 2
  rotation = lerp_angle(rotation, target_rotation, 1 - exp(-3 * get_process_delta_time()))


func on_area_entered(area: Area2D) -> void:
  # 防止经验球在飞近玩家的时候第二次触发on_area_entered
  # 延迟调用，因为该函数中不能修改碰撞
  Callable(disable_collection).call_deferred()

  var tween = create_tween()
  tween.set_parallel() # 并行
  tween.tween_method(tween_collected.bind(global_position), 0.0, 1.0, 0.8) \
    .set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
  tween.tween_property(sprite, "scale", Vector2(0.1, 0.1), 0.1).set_delay(0.7)
  tween.chain() # 在上面两个并行动画执行完再进入下面。防止过早结束
  tween.tween_callback(collected)


func collected() -> void:
  GameEvents.emit_experience_gained(1) # 触发信号
  queue_free()

func disable_collection() -> void:
  collosion_shape_2d.disabled = true