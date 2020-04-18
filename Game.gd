extends Spatial

onready var customer_scn = load("res://Customer/Customer.tscn")

func _ready():
	 randomize()

func _process(delta):
	check_for_orders()
	check_for_dishes()

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

func display_dishes_popup():
	$UI/DishesPopup.set_position(get_popup_position())
	$UI/DishesPopup.visible = true

# transform 3d position with main camera to 2d position on screen
func move_all_customers():
	for customer in $Customers.get_children():
		customer.move_two_unit()

func _on_OrderMenu_confirmed():
	$Customers.remove_child($Customers.get_child(0))
	move_all_customers()

func _on_DishesPopup_id_pressed(menu_id):
	make_dish(menu_id)

func make_dish(menu_id):
	print("make dish " + str(menu_id))

	# display progress bar

################
# Utils functions
#################
func get_popup_position():
	return $Camera.unproject_position($Player.translation)

func get_random_menu():
	var menu_id = randi() % 3
	if menu_id == 0:
		return "Red"
	elif menu_id == 1:
		return "Green"
	elif menu_id == 2:
		return "Blue"
