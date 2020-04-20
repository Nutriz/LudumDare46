extends KinematicBody
var navigation: Navigation
var path = []
var ray: RayCast
var path_ind = 0
var speed = 17
var motion = Vector3()
var randomNumberGen: RandomNumberGenerator;
var move_vec = Vector3()
export var gravity = 10;
var isEscaped = false
var is_holded = false
var dead

func _ready():
	ray = $RayCast;
	translation = Vector3(14.516,0.436,-5.292)
	randomNumberGen = RandomNumberGenerator.new();

func _physics_process(delta):

	if is_holded:
		return

	move_vec.y -= gravity
	if isEscaped :
		if ray.enabled:
			print(ray.enabled);
			if(ray.get_collision_point()):
				var point = ray.get_collision_point();
				path = navigation.get_simple_path(translation, point);
				ray.enabled = false


		if path_ind < path.size():
			move_vec = (path[path_ind] - global_transform.origin)
			if move_vec.length() < 1:
				path_ind += 1
			else:
				move_vec.y = 0
				move_and_slide(move_vec.normalized() * speed * delta, Vector3.UP)


func _on_Timer_timeout():
	randomRotate();
	$AudioStreamPlayer3D.play();
	ray.enabled = true;

func randomRotate():
	move_vec = Vector3();
	rotate_y(randomNumberGen.randf_range(-10, 10))
	path = []
	path_ind = 0


func _on_Timer_escape_timeout():
	translation = Vector3(13.496,0, -0.411)
	isEscaped = true;
	$AudioStreamPlayer3D.play();
	Autoload.babyphone.start_alert()
	$Timer_dead.start()

func _on_Timer_dead_timeout():
	dead = true
	print('le bébé est mort!!')

func putInBed():
	isEscaped = false
	is_holded = false
	Autoload.babyphone.stop_alert()
	translation = Vector3(14.516,0.436,-5.292)
	$Timer_dead.stop()
	$Timer_escape.wait_time = randomNumberGen.randf_range(10, 60)
	$Timer_escape.start();
	$AudioStreamPlayer3D.stop();


