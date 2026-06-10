extends Path2D

@export var speed = 150
@export var clockwise: bool = true

@onready var path_follow_2d = $PathFollow2D

func _physics_process(delta: float) -> void:
  if clockwise:
    path_follow_2d.progress += speed * delta
  else:
    path_follow_2d.progress -= speed * delta
    
