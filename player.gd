extends CharacterBody2D

@export var movement_data : PLayerMovementData

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@onready var wall_jump_timer = $WallJumpTimer

var faster = false
var air_jump = false 
var wall_jumped = false
var was_wall_normal = Vector2.ZERO

func _physics_process(delta):
	apply_gravity(delta)
	handel_wall_jump()
	handel_jump()
	var input_axis = Input.get_axis("ui_left", "ui_right")
	handel_acceleration(input_axis, delta)
	handel_air_acceleration(input_axis,delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal();
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	wall_jumped = false
	if Input.is_action_just_pressed("ui_accept") and !faster:
		movement_data = load("res://FasterMovementData.tres")
		faster = true
	elif Input.is_action_just_pressed("ui_accept") and faster:
		movement_data = load("res://DefaultDataMovement.tres")
		faster = false
	var just_left_wall = was_on_wall and not is_on_wall_only()
	if just_left_wall:
		wall_jump_timer.start()
		
		
func apply_gravity(delta):
		if not is_on_floor():
			velocity.y += gravity * movement_data.gravity_scale * delta
			
func handel_jump():
	if is_on_floor(): air_jump = true
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity/2:
			velocity.y = movement_data.jump_velocity * 1/2
		if Input.is_action_just_pressed("jump") and air_jump and not wall_jumped:
			print("double jump time")
			velocity.y = movement_data.jump_velocity * .8
			air_jump = false
			
func handel_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0: return
	var wall_normal = get_wall_normal();
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	if Input.is_action_just_pressed("jump") :
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		wall_jumped = true

func apply_friction(input_axis, delta):
	if(input_axis == 0 and is_on_floor()):
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if(input_axis == 0 and not is_on_floor()):
		velocity.x = move_toward(velocity.x,0, movement_data.air_resistance * delta)

func handel_acceleration(input_axis, delta):
	if not is_on_floor():
		return;
	if input_axis:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)
		
func handel_air_acceleration(input_axis,delta):
	if is_on_floor():
		return;
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)
		
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h =(input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(area):
	global_position = starting_position;

