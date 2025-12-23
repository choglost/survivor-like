extends Node

@export var health_component: Node
@export var sprite: Sprite2D
@export var hurt_anim_material: ShaderMaterial

var hurt_flash_tween: Tween

func _ready() -> void:
  health_component.health_changed.connect(on_health_changed)
  sprite.material = hurt_anim_material

func on_health_changed() -> void:
  if hurt_flash_tween != null && hurt_flash_tween.is_valid():
    hurt_flash_tween.kill()
  
  (sprite.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)
  hurt_flash_tween = create_tween()
  hurt_flash_tween.tween_property(sprite.material, "shader_parameter/lerp_percent", 0.0, 0.25) \
    .set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
