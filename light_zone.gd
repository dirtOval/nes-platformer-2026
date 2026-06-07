@tool
extends Area2D

@export var x: float
@export var y: float

func _process(delta):
  if Engine.is_editor_hint():
    $CollisionShape2D.shape.size.x = x
    $CollisionShape2D.shape.size.y = y
  

func _on_body_entered(body: Node2D) -> void:
  if body.is_in_group('player'):
    body.in_light = true
    if not body.human and not body.transforming:
      body.morph()
