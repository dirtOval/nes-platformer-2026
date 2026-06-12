extends Area2D

@export var speed = 100

var flipped: bool = false
#var target_position: Vector2

#@onready var path_follow_2d = $PathFollow2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass
  #curve.set_point_out(0, Vector2(target_position.x / 2, - abs(target_position.x)))
  #curve.set_point_out(0, Vector2(0, - abs(target_position.x)))
  #curve.set_point_in(1, Vector2(0, - abs(target_position.x)))
  #curve.set_point_position(1, target_position)

func _physics_process(delta: float) -> void:
  #if not target_position: return
  #
  #if path_follow_2d.progress_ratio >= 0.98: queue_free()
  #path_follow_2d.progress += speed * delta
  if flipped:
    position -= transform.x * speed * delta 
  else:
    position += transform.x * speed * delta
