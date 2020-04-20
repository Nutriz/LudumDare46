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

var table_for_eat

func _ready():
	move_lock_y = true

func _process(delta):
	pass

func _physics_process(delta):
	vel += gravity * delta
	if path == null:
		var current_ordering = false
		for customer in Autoload.order_zone.get_overlapping_bodies():
			if customer.get_name().begins_with("Customer"):
				return
		var space_state = get_world().direct_space_state
		var look_at = translation
		look_at.x += 2
#
#		print(result.values())
		vel.x = speed
		move_and_slide(vel, Vector3.UP)
	else:
		if path_ind < path.size():
			look_at(path[path_ind], Vector3.UP)
			var move_vec = (path[path_ind] - global_transform.origin)
			if move_vec.length() < 0.1:
				path_ind += 1
			else:
				move_and_slide(move_vec.normalized() * speed, Vector3.UP)
#		elif path_ind == path.size():
#			print("at pos")
#			path_ind += 1
#			look_at(table_for_eat.get_node("PlatePosition").translation, Vector3.UP)

func move_two_unit():
	target_x = translation.x + 1.5

func served(served_id_menu):
	print("Served menu: " + str(served_id_menu) + ", ordered: " + str(ordered_id_menu))
	$EatTimer.start()
	if ordered_id_menu != served_id_menu:
		happiness -= 1
		Autoload.bad_sound.play()
		Autoload.popularity_progress_bar.value = Autoload.popularity_progress_bar.value - 1
	else:
		Autoload.great_sound.play()

func _on_EatTimer_timeout():
	table_for_eat.is_free = true
	queue_free()
