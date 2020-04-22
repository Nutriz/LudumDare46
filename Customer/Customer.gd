extends KinematicBody

var gravity = Vector3.DOWN * 10
var vel = Vector3()
export var speed = 3

var path
var path_ind = 0

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
		for customer in Autoload.order_zone.get_overlapping_bodies():
			if customer.get_name().begins_with("Customer") or customer.get_name().begins_with("@Customer"):
				return
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
		elif path_ind == path.size():
			print("at pos")
			path_ind += 1
			$WaitingDishTimer.start()

func move_two_unit():
	target_x = translation.x + 1.5

func served(served_id_menu):
	print("Served menu: " + str(served_id_menu) + ", ordered: " + str(ordered_id_menu))
	$WaitingDishTimer.stop()
	$EatTimer.start()
	if ordered_id_menu != served_id_menu:
		Autoload.bad_sound.play()
		Autoload.popularity_progress_bar.value = Autoload.popularity_progress_bar.value - 1
	else:
		Autoload.great_sound.play()
		Autoload.popularity_progress_bar.value = Autoload.popularity_progress_bar.value + 3

func start_dish_timer():
	$WaitingDishTimer.start()

func _on_EatTimer_timeout():
	queue_free()

func _on_WaitingTimer_timeout():
	print("-1 popularity")
	Autoload.popularity_progress_bar.value = Autoload.popularity_progress_bar.value - 1
