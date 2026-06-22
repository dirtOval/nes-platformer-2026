extends CharacterBody2D

var bullet = preload("res://skeleton_bullet.tscn")

@export var speed: float = 100.0
@export var path_radius: float = 50
@export var facing_right: bool = true
@export var sight_range: float = 200

@onready var timer = $CooldownTimer
@onready var sprite = $AnimatedSprite2D

var anchor_position: float
var shooting: bool = false
#var shooting_target: Vector2
var can_move = true
var animating = false

func _ready() -> void:
  anchor_position = position.x
  #print(anchor_position)
  
#func update_graphic() -> void:
  #if shooting:
    #sprite.play('attack')
  
func shoot() -> void:
  animating = true
  shooting = true
  sprite.play('attack')
  await get_tree().create_timer(.32).timeout
  animating = false
  var shoot_marker = $ShootMarker
  var b = bullet.instantiate()
  b.global_position = shoot_marker.global_position
  #b.target_position = shooting_target
  owner.add_child(b)
  if sprite.flip_h:
    b.flipped = true
  var coin_flip = randi_range(0, 1)
  print(coin_flip)
  if coin_flip == 1:
    facing_right = not facing_right
  timer.start()
  
func die() -> void:
  can_move = false
  await get_tree().create_timer(.48).timeout
  sprite.play('die')
  queue_free()
  
func _physics_process(delta: float) -> void:
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta
    

  #player detection +
  if timer.is_stopped() and shooting == false:
    var vision = sight_range
    if not facing_right:
      vision *= -1
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(
      Vector2(global_position.x, global_position.y - 8),
      Vector2(global_position.x + vision, global_position.y))
    query.exclude = [self]
    var result = space_state.intersect_ray(query)
    if result and result.collider.is_in_group('player'):
      print('pew!')
      #shooting = true
      #shooting_target = result.position
      #print(shooting_target)
      shoot()
    
  #movement along path
  if can_move and not animating:
    sprite.play('walk')
    if facing_right:
      if position.x >= anchor_position + path_radius:
        #here is where i flip the sprite, when there is one
        sprite.flip_h = true
        facing_right = false
        $ShootMarker.position.x = -12
      else:
        position += transform.x * speed * delta
    else:
      if position.x <= anchor_position - path_radius:
        #flip the spriteee
        sprite.flip_h = false
        facing_right = true
        $ShootMarker.position.x = 12
      else:
        position -= transform.x * speed * delta
  move_and_slide()
  #for i in get_slide_collision_count():
    #var collision = get_slide_collision(i)
    #if collision.get_collider().is_in_group('p_bullet'):
      #queue_free
      #break


func _on_cooldown_timer_timeout() -> void:
  shooting = false
