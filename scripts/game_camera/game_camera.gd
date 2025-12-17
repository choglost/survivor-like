extends Camera2D

const RATE = 20

var target_position: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	acquire_target()
	# global_position = global_position.lerp(target_position, 1.0 - exp(-delta * RATE)) # 帧率无关的线性插值
	global_position = target_position

func acquire_target():
	var player_node = get_tree().get_nodes_in_group("player")
	if player_node.size() > 0:
		var player = player_node[0] as Node2D
		target_position = player.global_position
