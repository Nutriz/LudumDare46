extends KinematicBody
var navigation: Navigation

const SPEED = 0.6
var vel = Vector3()

var move_vec = Vector3()
var is_escaped = false
var escape_path
var path_index = 0
var is_holded = false
var dead

func _ready():
	start_next_escape_cycle()

func _physics_process(delta):
	if escape_path != null and not is_holded:
		if path_index < escape_path.size():
			move_vec = escape_path[path_index] - global_transform.origin
			if move_vec.length() < 1:
				path_index += 1
			else:
				$Mesh.look_at(escape_path[path_index], Vector3.UP)
				move_and_slide(move_vec.normalized() * SPEED, Vector3.UP)
		else:
			set_random_pos_to_walk(escape_path[escape_path.size() - 1])

func put_in_bed(new_pos):
	print("put in bed")
	Autoload.popularity_progress_bar.value = Autoload.popularity_progress_bar.value + 1
	is_holded = false
	start_next_escape_cycle()
	Autoload.babyphone.stop_alert()
	translation = new_pos
	$DeadTimer.stop()

func start_next_escape_cycle():
	randomize()
	$BabySound.stop()
	$NextEscapeTimer.start(20 + randi() % 80);

func _on_NextEscapeTimer_timeout():
	print("baby escaped")
	is_escaped = true
	set_random_pos_to_walk(null)
	$BabySound.play()
	Autoload.babyphone.start_alert()
	$DeadTimer.start()

func set_random_pos_to_walk(from):
	var positions = get_tree().get_nodes_in_group("BabyPos")
	positions.shuffle()

	var start_pos
	if from != null:
		start_pos = from
	else:
		start_pos = positions.pop_front().translation

	translation = start_pos
	var end_pos = positions.pop_front().translation
	escape_path = get_parent().get_node("NavigationBaby").get_simple_path(start_pos, end_pos)

	path_index = 0

func _on_DeadTimer_timeout():
	Autoload.popularity_progress_bar.value = Autoload.popularity_progress_bar.value - 1

func holded(new_pos):
	is_holded = true
	escape_path = null
	translation = new_pos
