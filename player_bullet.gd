extends Area2D

var flipped: bool = false

@export var speed = 150
var hit: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if flipped:
    $AnimatedSprite2D.flip_h = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
  if not hit:
    if flipped:
      position -= transform.x * speed * delta 
    else:
      position += transform.x * speed * delta


func _on_body_entered(body: Node2D) -> void:
  if body.is_in_group('enemy'):
    body.die()
  hit = true
  $AnimatedSprite2D.play('burst')
  await get_tree().create_timer(.32).timeout
  queue_free()
