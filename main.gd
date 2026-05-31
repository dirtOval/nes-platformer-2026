extends Node2D

const player = preload("res://player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


func _process(delta: float) -> void:
  if Input.is_action_just_pressed("reset"):
    print("reset scene")
    if $Camera2D:
      $Camera2D.queue_free()
    get_tree().reload_current_scene() 
