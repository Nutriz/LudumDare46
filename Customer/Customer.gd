extends KinematicBody

var gravity = Vector3.DOWN * 10
var vel = Vector3()
export var speed = 5
export var rotate_speed = 0.1
export var MAX_SPEED = 4

var happiness = 3 # 1 = sad, 3 = happy
var hungry = 2    # 1 = not hungry, 4 = very hungry

var target_x

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	vel += gravity * delta
	if (target_x != null and translation.x <= target_x):
		vel.x += 0.05
	else:
		vel.x = 0

	vel = move_and_slide(vel, Vector3.UP)

func move_two_unit():
	target_x = translation.x + 2
