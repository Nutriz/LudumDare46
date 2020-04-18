extends Spatial

onready var customer_scn = load("res://Customer/Customer.tscn")

func _process(delta):
	if (Input.is_action_pressed("quit")):
		get_tree().quit()

	if (Input.is_action_just_released("switch_camera")):
		$Camera.current = !$Camera.current

	if (Input.is_action_just_released("action")):
		var first = $Customers.get_children().front()
		if (first != null):
			$Customers.remove_child(first)
			move_all_customers()


func add_new_customer():
	var customer = customer_scn.instance()
	customer.translation = $SpawnCustomer.translation
	var look_at = Vector3($OrderLookAtPosition.translation.x, 1.5, $OrderLookAtPosition.translation.z)
	customer.look_at_from_position($OrderPosition.translation, look_at, Vector3.UP)
	$Customers.add_child(customer)

func move_all_customers():
	for c in $Customers.get_children():
		c.move_two_unit()

