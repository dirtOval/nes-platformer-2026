extends CharacterBody2D


@export var SPEED = 200.0
@export var JUMP_VELOCITY = -400.0

var on_floor_ref = true

#physics process frame are fixed at 60/second
@export var coyote_frames: int = 6
var coyote_timer: int = 0


func _physics_process(delta: float) -> void:
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta
    
  # Handle jump.
  if Input.is_action_just_pressed("jump"):
    if is_on_floor() or coyote_timer > 0:
      velocity.y = JUMP_VELOCITY
  
  if coyote_timer > 0:
    coyote_timer -= 1
    
  if is_on_floor() != on_floor_ref:
    if on_floor_ref == true:
      coyote_timer = coyote_frames
  on_floor_ref = is_on_floor()
  
  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
  var direction := Input.get_axis("left", "right")
  if direction:
    velocity.x = direction * SPEED
  else:
    velocity.x = move_toward(velocity.x, 0, SPEED)

  move_and_slide()

func die() -> void:
  var camera = $Camera2D
  var camera_position = camera.global_position
  remove_child($Camera2D)
  get_tree().root.add_child(camera)
  camera.position_smoothing_enabled = false
  camera.global_position = camera_position
  queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
  die()
