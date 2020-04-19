extends KinematicBody

var gravity = Vector3.DOWN * 10
var vel = Vector3()
export var speed = 3

var path
var path_ind = 0

var happiness = 3 # 1 = sad, 3 = happy
#var hungry = 2    # 1 = not hungry, 4 = very hungry

var target_x

var ordered_id_menu

func _ready():
	move_lock_y = true

func _process(delta):
	pass

func _physics_process(delta):
	vel += gravity * delta

	if path != null:
		if path_ind < path.size():
			var look_to = Vector3(path[path_ind])
			look_at(path[path_ind], Vector3.UP)
			var move_vec = (path[path_ind] - global_transform.origin)
			if move_vec.length() < 0.1:
				path_ind += 1
			else:
				move_and_slide(move_vec.normalized() * speed, Vector3.UP)
		else:
			rotate_y(-90)
			path = null
	elif target_x != null and translation.x <= target_x:
		vel.x += 0.05
		vel = move_and_slide(vel, Vector3.UP)
	else:
		vel.x = 0
		target_x = null

func move_two_unit():
	target_x = translation.x + 2

func served(served_id_menu):
	print("Served menu: " + str(served_id_menu) + ", ordered: " + str(ordered_id_menu))
	$EatTimer.start()
	if ordered_id_menu != served_id_menu:
		happiness -= 1
	# TODO play some grumpy sound


func _on_EatTimer_timeout():
	queue_free()
