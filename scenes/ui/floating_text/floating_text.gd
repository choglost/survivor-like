extends Node2D

func _ready() -> void:
  pass

func start(damage: float) -> void:
  var format_string = "%0.0f"

  $Label.text = format_string % damage
  var tween = create_tween()

  # 伤害数字先浮动上升16px
  tween.set_parallel()
  tween.tween_property(self, "global_position", global_position + Vector2.UP * 16, 0.3) \
    .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
 
  tween.chain()

  # 再上升16px
  tween.tween_property(self, "global_position", global_position + Vector2.UP * 32, 0.5) \
    .set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
  tween.tween_property(self, "scale", Vector2.ONE, 0.5) \
    .set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
  tween.chain()

  var tween_scale = create_tween()

  tween_scale.tween_property(self, "scale", Vector2.ONE * 1.4, 0.3) \
    .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
  
  tween.tween_callback(queue_free)