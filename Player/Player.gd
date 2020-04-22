extends KinematicBody

var gravity = Vector3.DOWN * 10
var vel = Vector3()
export var speed = 4
export var rotate_speed = 0.05
export var MAX_SPEED = 4

var holding_plate
var dirty_plate_count = 0

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	vel += gravity * delta
	handle_input()
	vel = move_and_slide(vel, Vector3.UP)

#### WORKING but without lerp
func handle_input():
	vel.x = 0
	vel.z = 0
	if (Input.is_action_pressed("up")):
		vel += -transform.basis.z * speed

	if (Input.is_action_pressed("left")):
		rotate_y(rotate_speed)
	elif (Input.is_action_pressed("right")):
		rotate_y(-rotate_speed)

	if (abs(vel.x) > MAX_SPEED):
		vel.x = MAX_SPEED * sign(vel.x)
	if (abs(vel.z) > MAX_SPEED):
		vel.z = MAX_SPEED * sign(vel.z)

func take_ready_plate(plate):
	if dirty_plate_count < 1:
		holding_plate = plate
		plate.translation = $PlatePosition.translation
		add_child(plate)
		print("player holding plate id: " + str(holding_plate.type))

func take_dirty_plate(plate):
	plate.get_parent().remove_child(plate)
	dirty_plate_count += 1
	refresh_dirty_plates()

func remove_dirty_plate():
	dirty_plate_count -= 1
	refresh_dirty_plates()

func refresh_dirty_plates():
	for plate in $DirtyPlates.get_children():
		plate.visible = false

	for plate_index in dirty_plate_count:
		$DirtyPlates.get_child(plate_index).visible = true

func remove_plate():
	remove_child(holding_plate)
	holding_plate = null

func hold_baby(baby):
	baby.holded($BabyPosition.translation)
	add_child(baby)
