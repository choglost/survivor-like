extends AudioStreamPlayer

@export var streams: Array[AudioStream]
@export var randomlize_pitch: bool = true

var min_pitch: float = 0.8
var max_pitch: float = 1.2


func play_random_audio():
  if streams == null or streams.size() == 0:
    return
  
  if randomlize_pitch:
    pitch_scale = randf_range(min_pitch, max_pitch)
  else:
    pitch_scale = 1

  stream = streams.pick_random()
  play()