extends Spatial

onready var customer_scn = load("res://Customer/Customer.tscn")
onready var plate_scn = load("res://Scenes/Plate.tscn")

var move_to_apartment
var next_menu

func _ready():
	randomize()

func _process(delta):
	move_camera()

func _physics_process(delta):
	check_for_orders()
	check_for_dishes()
	check_for_holding_plate()
	check_for_serving_plate()

	if Input.is_action_pressed("quit"):
		get_tree().quit()

	if Input.is_action_just_released("switch_camera"):
		$Camera.current = !$Camera.current

#func add_new_customer():
#	var customer = customer_scn.instance()
#	customer.translation = $SpawnCustomer.translation
#	var look_at = Vector3($OrderLookAtPosition.translation.x, 1.5, $OrderLookAtPosition.translation.z)
#	customer.look_at_from_position($OrderPosition.translation, look_at, Vector3.UP)
#	$Customers.add_child(customer)

func check_for_orders():
	if Input.is_action_just_released("action") and not $Customers.get_children().empty():
		print()
		if $OrderZone.overlaps_body($Player):
			display_order_popup()

func display_order_popup():
	var pos = $Camera.unproject_position($Customers.get_child(0).translation)
	pos.y -= 100

	$UI/OrderMenu.dialog_text = "Hi, I want a " + get_random_menu() + " menu please !"
	$UI/OrderMenu.set_position(pos)
	$UI/OrderMenu.visible = true

func check_for_dishes():
	if Input.is_action_just_released("action"):
		if $DishesZone.overlaps_body($Player):
			display_dishes_popup()
		elif $CleanPlates.get_children().empty():
			# TODO display "no clean plate" message
			pass

func display_dishes_popup():
	$UI/DishesPopup.set_position(get_popup_position())
	$UI/DishesPopup.visible = true

func check_for_holding_plate():
	if Input.is_action_just_released("action"):
		for plate in $ReadyPlates.get_children():
			if $Player.holding_plate == null and plate.get_node("Area").overlaps_body($Player):
				$Player.take_plate(plate.type)
				$ReadyPlates.remove_child(plate)

func check_for_serving_plate():
	if Input.is_action_just_released("action") and $Player.holding_plate != null:
		for table_area in $Tables.get_children():
			if table_area.get_class() == "Area" and table_area.overlaps_body($Player):
				for customers in $TableCustomers.get_children():
					print("customer overlap " + table_area.name + " " + str(table_area.overlaps_body(customers)))
					if table_area.overlaps_body(customers):
						customers.served($Player.holding_plate)
						var plate = plate_scn.instance()
						plate.translation = $Tables/Table1/PlatePosition.translation
						print("pos: " + str($Tables/Table1/PlatePosition.translation))
						print("plate pos: " + str(plate.translation))
						$Tables/Table1/PlatePosition.add_child(plate)
						$Player.holding_plate = null

func _on_OrderMenu_confirmed():
	var current_customer = $Customers.get_child(0)
	current_customer.ordered_id_menu = next_menu
	current_customer.path = $Navigation.get_simple_path(current_customer.global_transform.origin, $Tables/Table1.translation)

	$Customers.remove_child(current_customer)
	$TableCustomers.add_child(current_customer)

	move_all_customers()

# transform 3d position with main camera to 2d position on screen
func move_all_customers():
	for customer in $Customers.get_children():
		customer.move_two_unit()

func _on_DishesPopup_id_pressed(menu_id):
	spawn_new_plate(menu_id)

func make_dish(menu_id):
	print("make dish " + str(menu_id))

	# display progress bar

func spawn_new_plate(menu_id):
	var plate_to_remove = $CleanPlates.get_child(0)
	if plate_to_remove != null:
		$CleanPlates.remove_child(plate_to_remove)
	#	for a in 50:
		for plate in $ReadyPlates.get_children():
			print("move")
			plate.apply_impulse(Vector3(), Vector3.BACK * 4)

	#	for a in 50:
		var plate = plate_scn.instance()
		plate.type = menu_id
		plate.translation = $PlateSpawnerPosition.translation
		# TODO change color regarding menu id
		$ReadyPlates.add_child(plate)

#		plate.get_node("Particles").emitting = true


################
# Utils functions
#################
func get_popup_position():
	return $Camera.unproject_position($Player.translation)

func get_random_menu():
	next_menu = randi() % 3
	if next_menu == 0:
		return "Red"
	elif next_menu == 1:
		return "Green"
	elif next_menu == 2:
		return "Blue"


func _on_DoorZone_body_exited(body):
	move_to_apartment = !move_to_apartment

func move_camera():
	if move_to_apartment:
		$Camera.translation = $Camera.translation.linear_interpolate($CameraPositionApartment.translation, 0.05)
	else:
		$Camera.translation = $Camera.translation.linear_interpolate($CameraPositionRestaurant.translation, 0.05)

