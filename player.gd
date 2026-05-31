extends CharacterBody2D


@export var MAX_SPEED = 200.0
@export var JUMP_VELOCITY = -500
@export var WALLJUMP_VELOCITY = -450
@export var ACCELERATION = 1000
@export var FRICTION = 1200
@export var FALL_MODIFIER = 1.1
@export var JUMP_CUT = 125
@export var WALLSLIDE_SLOWDOWN = 0.85
@export var WALLJUMP_INPUT_FREEZE = 0.1
@export var AIR_FRICTION = 400


var on_floor_ref: bool = true
var human: bool = false
var can_move: bool = true

#physics process frame are fixed at 60/second
@export var coyote_frames: int = 6
var coyote_timer: int = 0
var walljump_timer: int = 0

func jump(x: float = 0) -> void:
  #wall jump!
  if x != 0:
    #disable player input for a few frames
    can_move = false
    velocity.x = x * abs(WALLJUMP_VELOCITY * 0.85)
    velocity.y = WALLJUMP_VELOCITY
    await get_tree().create_timer(WALLJUMP_INPUT_FREEZE).timeout
    can_move = true
  #regular ol jump
  else:
    velocity.y = JUMP_VELOCITY
    
func morph() -> void:
  human = not human
  print("is human? " + str(human))
  var creature_sprite = $CreaturePolygon
  var human_sprite = $HumanPolygon
  var collider = $CollisionShape2D
  var rectangle = collider.shape
  if human:
    creature_sprite.hide()
    human_sprite.show()
    rectangle.size.y = 40
    collider.position.y = -10
  else:
    human_sprite.hide()
    creature_sprite.show()
    rectangle.size.y = 20
    collider.position.y = 0
    

func _physics_process(delta: float) -> void:
   
  var direction := Input.get_axis("left", "right")
  if direction and can_move:
    velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION * delta)
  else:
    if not is_on_floor():
      #if we're rising in the jump we have less control of momentum, more while falling
      if velocity.y >= 0:
        velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)
      else:
        velocity.x = move_toward(velocity.x, 0, (AIR_FRICTION/2) * delta)
        
    else:
      velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
    
  # Add the gravity.
  if not is_on_floor():
    var gravity = get_gravity()
    if is_on_wall() and velocity.y >= 0:
      velocity.y += (gravity.y * WALLSLIDE_SLOWDOWN) * delta
    elif velocity.y > 0:
      velocity.y += (gravity.y + FALL_MODIFIER) * delta
    else:
      velocity.y += gravity.y * delta
      
  if Input.is_action_just_pressed("transform"):
    morph()
    
  
  # Handle jump.
  if Input.is_action_just_pressed("jump") and can_move:
    if is_on_floor() or coyote_timer > 0:
      jump()
    if is_on_wall() and not is_on_floor():
        var jump_vector = get_wall_normal()
        jump(jump_vector.x)
  if Input.is_action_just_released("jump"):
    if velocity.y <= JUMP_VELOCITY / 3:
      velocity.y += JUMP_CUT
  
  #Timer decrement zone
  if coyote_timer > 0:
    coyote_timer -= 1
  if walljump_timer > 0:
    coyote_timer -= 1
  
  #if the last and current is_on_floor return aren't equal and the last one is true,
  #then the player just left the ground
  if is_on_floor() != on_floor_ref:
    if on_floor_ref == true:
      coyote_timer = coyote_frames
  on_floor_ref = is_on_floor()

  move_and_slide()

func die() -> void:
  var camera = $Camera2D
  var camera_position = camera.global_position
  remove_child($Camera2D)
  get_tree().root.get_node("Main").add_child(camera)
  camera.position_smoothing_enabled = false
  camera.global_position = camera_position
  queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
  die()
