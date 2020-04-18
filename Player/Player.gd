extends KinematicBody

var gravity = Vector3.DOWN * 10
var vel = Vector3()
export var speed = 5
export var rotate_speed = 0.1
export var MAX_SPEED = 4

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	vel += gravity * delta
	handle_input()
	vel = move_and_slide(vel, Vector3.UP)

func handle_input():
	var vy = vel.y

	var acc = Vector3()

	if (Input.is_action_pressed("up")):
		acc += -transform.basis.z * speed
	elif (Input.is_action_pressed("down")):
		acc += transform.basis.z * speed
	else:
		vel *= 0.9

	if (Input.is_action_pressed("left")):
		rotate_y(rotate_speed)
	elif (Input.is_action_pressed("right")):
		rotate_y(-rotate_speed)

	vel += acc
	vel.y = vy

	vel.x = clamp(vel.x, -speed, speed)
	vel.z = clamp(vel.z, -speed, speed)

#### WORKING but without lerp
#func handle_input():
#	var vy = vel.y
#	var velocity = vel
#
#	if (Input.is_action_pressed("up")):
#		velocity += -transform.basis.z * speed
#	else:
#		vel = vel * 0.9
#
#	if (Input.is_action_pressed("left")):
#		rotate_y(rotate_speed)
#	elif (Input.is_action_pressed("right")):
#		rotate_y(-rotate_speed)
#
#	vel = velocity
#	vel.y = vy
#	if (abs(vel.x) > MAX_SPEED):
#		vel.x = MAX_SPEED * sign(vel.x)
#	if (abs(vel.z) > MAX_SPEED):
#		vel.z = MAX_SPEED * sign(vel.z)
