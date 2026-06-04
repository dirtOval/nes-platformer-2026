extends CharacterBody2D

#CREATURE STATS
@export var C_SPEED = 300
@export var C_JUMP_VELOCITY = -500
@export var C_WALLJUMP_VELOCITY = -400
@export var C_ACCELERATION = 1000
@export var C_FRICTION = 2250
@export var C_FALL_MODIFIER = 1.1
@export var C_JUMP_CUT = 150
@export var C_WALLSLIDE_SLOWDOWN = 0.5
@export var C_WALLJUMP_INPUT_FREEZE = 0.1
@export var C_AIR_FRICTION = 750


#HUMAN STATS
#CREATURE STATS
@export var H_SPEED = 200.0
@export var H_JUMP_VELOCITY = -500
@export var H_WALLJUMP_VELOCITY = -450
@export var H_ACCELERATION = 1000
@export var H_FRICTION = 1200
@export var H_FALL_MODIFIER = 1.1
@export var H_JUMP_CUT = 125
@export var H_WALLSLIDE_SLOWDOWN = 0.85
@export var H_WALLJUMP_INPUT_FREEZE = 0.1
@export var H_AIR_FRICTION = 400

#WORKING STATS
@onready
var active_sprite = $CatSprite

var speed = C_SPEED
var jump_velocity = C_JUMP_VELOCITY
var walljump_velocity = C_WALLJUMP_VELOCITY
var acceleration = C_ACCELERATION
var friction = C_FRICTION
var fall_modifier = C_FALL_MODIFIER
var jump_cut = C_JUMP_CUT
var wallslide_slowdown = C_WALLSLIDE_SLOWDOWN
var walljump_input_freeze = C_WALLJUMP_INPUT_FREEZE
var air_friction = C_AIR_FRICTION


#bool flags
var on_floor_ref: bool = true
var human: bool = false
var can_move: bool = true
var transforming: bool = false

#physics process frame are fixed at 60/second
@export var coyote_frames: int = 6
var coyote_timer: int = 0
var walljump_timer: int = 0

func jump(x: float = 0) -> void:
  #wall jump!
  if x != 0:
    #disable player input for a few frames
    can_move = false
    velocity.x = x * abs(C_WALLJUMP_VELOCITY * 0.85)
    velocity.y = C_WALLJUMP_VELOCITY
    active_sprite.flip_h = not active_sprite.flip_h
    await get_tree().create_timer(C_WALLJUMP_INPUT_FREEZE).timeout
    can_move = true
  #regular ol jump
  else:
    velocity.y = C_JUMP_VELOCITY
    
func swap_stats() -> void:
  if human:
    print('human stats')
    speed = H_SPEED
    jump_velocity = H_JUMP_VELOCITY
    walljump_velocity = H_WALLJUMP_VELOCITY
    acceleration = H_ACCELERATION
    friction = H_FRICTION
    fall_modifier = H_FALL_MODIFIER
    jump_cut = H_JUMP_CUT
    wallslide_slowdown = H_WALLSLIDE_SLOWDOWN
    walljump_input_freeze = H_WALLJUMP_INPUT_FREEZE
    air_friction = H_AIR_FRICTION 
    
  else:
    speed = C_SPEED
    jump_velocity = C_JUMP_VELOCITY
    walljump_velocity = C_WALLJUMP_VELOCITY
    acceleration = C_ACCELERATION
    friction = C_FRICTION
    fall_modifier = C_FALL_MODIFIER
    jump_cut = C_JUMP_CUT
    wallslide_slowdown = C_WALLSLIDE_SLOWDOWN
    walljump_input_freeze = C_WALLJUMP_INPUT_FREEZE
    air_friction = C_AIR_FRICTION
    print('creature stats')
    
func morph() -> void:
  var cat_sprite = $CatSprite
  var human_sprite = $HumanSprite
  var collider = $CollisionShape2D
  var rectangle = collider.shape
  active_sprite.play("transform")
  if human:
    active_sprite.position.x = 1
  if not human:
    active_sprite.position.y = -16
  transforming = true
  await get_tree().create_timer(.57).timeout
  transforming = false
  human = not human
  print("is human? " + str(human))
  if human:
    cat_sprite.hide()
    human_sprite.show()
    active_sprite = human_sprite
    active_sprite.position.x = 2
    active_sprite.position.y = -16
    rectangle.size.x = 12
    rectangle.size.y = 28
    collider.position.x = 2
    collider.position.y = -14
  else:
    human_sprite.hide()
    cat_sprite.show()
    active_sprite = cat_sprite
    active_sprite.position.x = 0
    active_sprite.position.y = -8
    rectangle.size.x = 13
    rectangle.size.y = 12
    collider.position.x = 1.5
    collider.position.y = -6
  
  
  #finish transformation then change stats
  swap_stats()
    

func _physics_process(delta: float) -> void:
   
  var direction := Input.get_axis("left", "right")
  if direction and can_move:
    velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
    if not transforming: 
      active_sprite.play('run')
    if direction < 0:
      active_sprite.flip_h = true
    elif direction > 0:
      active_sprite.flip_h = false
  else:
    if not is_on_floor():
      #if we're rising in the jump we have less control of momentum, more while falling
      if velocity.y >= 0:
        velocity.x = move_toward(velocity.x, 0, air_friction * delta)
      else:
        velocity.x = move_toward(velocity.x, 0, (air_friction/2) * delta)
        
    else:
      velocity.x = move_toward(velocity.x, 0, friction * delta)
      if not transforming:
        active_sprite.play('idle')
    
  # Add the gravity.
  if not is_on_floor():
    if not transforming:
      active_sprite.play("jump", 1.0, true)
    var gravity = get_gravity()
    if is_on_wall() and velocity.y >= 0:
      velocity.y += (gravity.y * wallslide_slowdown) * delta
    elif velocity.y > 0:
      velocity.y += (gravity.y + fall_modifier) * delta
    else:
      velocity.y += gravity.y * delta
      
  if Input.is_action_just_pressed("transform") and not transforming:
    morph()
    
    
    
  
  # Handle jump.
  if Input.is_action_just_pressed("jump") and can_move:
    if not transforming:
      active_sprite.play('jump')
    if is_on_floor() or coyote_timer > 0:
      jump()
    if is_on_wall() and not is_on_floor():
        var jump_vector = get_wall_normal()
        jump(jump_vector.x)
  if Input.is_action_just_released("jump"):
    if velocity.y <= jump_velocity / 2:
      print('bunny hop ' + str(velocity.y))
      velocity.y += jump_cut * 1.25
    elif velocity.y <= jump_velocity / 3:
      print('middle jump ' + str(velocity.y))
      
      velocity.y += jump_cut
  
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
