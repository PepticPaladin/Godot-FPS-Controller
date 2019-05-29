extends KinematicBody

var camera_angle : float
var mouse_sensitivity : float
var camera_change : Vector2

var velocity : Vector3
var direction : Vector3

#fly variables
const FLY_SPEED : float = 20.0
const FLY_ACCEL : float = 4.0

var flying : bool

#walk variables
const GRAVITY : float = -9.8 * 3
const MAX_SPEED : float = 20.0
const MAX_RUNNING_SPEED : float = 30.0
const ACCEL : float = 2.0
const DEACCEL : float = 6.0

#jumping
const JUMP_HEIGHT : float = 15.0

var in_air : int
var has_contact : bool

#slope variables
const MAX_SLOPE_ANGLE : int = 35

onready var mainNode : Spatial = get_node("..") #Gets gary's parent, the Main node in this case

func _ready():
	camera_angle = 0
	mouse_sensitivity = 0.3
	camera_change = Vector2()
	
	velocity = Vector3()
	direction = Vector3()
	
	flying = false
	
	in_air = 0
	has_contact = false
	
	
	mainNode.invOpen = false

func _physics_process(delta):
	if !mainNode.invOpen:
		aim()
	if flying:
		fly(delta)
	else:
		walk(delta)

func _input(event):
	if event is InputEventMouseMotion:
		camera_change = event.relative
		
func walk(delta):
	# reset the direction of the player
	direction = Vector3()
	
	# get the rotation of the camera
	var aim = $Head/Camera.get_global_transform().basis
	
	# check input and change direction
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	direction.y = 0
	direction = direction.normalized()
	
	if (is_on_floor()):
		has_contact = true
		var n = $Tail.get_collision_normal()
		var floor_angle = rad2deg(acos(n.dot(Vector3(0, 1, 0))))
		if floor_angle > MAX_SLOPE_ANGLE: # only apply GRAVITY if angle of floor is steep enough
			velocity.y += GRAVITY * delta
		
	else:
		if !$Tail.is_colliding():
			has_contact = false
		velocity.y += GRAVITY * delta

	if (has_contact and !is_on_floor()):
		move_and_collide(Vector3(0, -1, 0))
	
	
	var temp_velocity = velocity # only stores x and z velocities to not affect y velocity.
	temp_velocity.y = 0
	
	var speed
	if Input.is_action_pressed("move_sprint"):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	
	# where would the player go at max speed
	var target = direction * speed
	
	#use dot product to test if temp_velocity and direction are going the same direction
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	# calculate a portion of the distance to go
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	if has_contact and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_HEIGHT
		has_contact = false
	
	# move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0)) # 2nd argument says what way is up, which lets functions like is_on_floor() work
	
	if !has_contact:
		print(in_air)
		in_air += 1
		
	$StairCatcher.translation.x = direction.x
	$StairCatcher.translation.z = direction.z
	
func fly(delta):
	# reset the direction of the player
	direction = Vector3()
	
	# get the rotation of the camera
	var aim = $Head/Camera.get_global_transform().basis
	
	# check input and change direction
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	
	direction = direction.normalized()
	
	# where would the player go at max speed
	var target = direction * FLY_SPEED
	
	# calculate a portion of the distance to go
	velocity = velocity.linear_interpolate(target, FLY_ACCEL * delta)
	
	# move
	move_and_slide(velocity)
	
func aim():
	if camera_change.length() > 0:
		$Head.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))

		var change = -camera_change.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		camera_change = Vector2()


func _on_Area_body_entered( body ):
	if body.name == "Gary":
		flying = true


func _on_Area_body_exited( body ):
	if body.name == "Gary":
		flying = false
