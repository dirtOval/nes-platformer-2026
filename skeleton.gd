extends CharacterBody2D

@export var speed: float = 100.0
@export var path_radius: float = 50
@export var facing_right: bool = true
@export var sight_range: float = 200

var anchor_position: float

func _ready() -> void:
  anchor_position = position.x
  #print(anchor_position)

func _physics_process(delta: float) -> void:
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta

  #player detection + 
  var vision = sight_range
  if not facing_right:
    vision *= -1
  var space_state = get_world_2d().direct_space_state
  var query = PhysicsRayQueryParameters2D.create(
    Vector2(global_position.x, global_position.y - 8), Vector2(global_position.x + vision, global_position.y))
  query.exclude = [self]
  var result = space_state.intersect_ray(query)
  if result and result.collider.is_in_group('player'):
    print('i see you!')
  

  #movement along path
  if facing_right:
    if position.x >= anchor_position + path_radius:
      #here is where i flip the sprite, when there is one
      #$Polygon2D.flip_h = true
      facing_right = false
    else:
      position += transform.x * speed * delta
  else:
    if position.x <= anchor_position - path_radius:
      #flip the spriteee
      #$Polygon2D.flip_h = false
      facing_right = true
    else:
      position -= transform.x * speed * delta
  move_and_slide()
  #for i in get_slide_collision_count():
    #var collision = get_slide_collision(i)
    #if collision.get_collider().is_in_group('p_bullet'):
      #queue_free
      #break
