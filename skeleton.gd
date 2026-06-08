extends CharacterBody2D


func _physics_process(delta: float) -> void:
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta

  move_and_slide()
  #for i in get_slide_collision_count():
    #var collision = get_slide_collision(i)
    #if collision.get_collider().is_in_group('p_bullet'):
      #queue_free
      #break
