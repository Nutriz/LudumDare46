extends Spatial

onready var customer_scn = load("res://Customer/Customer.tscn")
onready var plate_scn = load("res://Scenes/PlateStatic.tscn")
onready var plate_clean_scn = load("res://Scenes/Plate.tscn")

var move_to_apartment
var next_menu

var baby

var lock_order = false

func _ready():

	$Baby.translation = $BabyCraddlePosition.translation

	get_tree().paused = true

	$World/Apartment/Mesh.mesh.surface_get_material(0).params_blend_mode = 1
	$UI/WelcomeDialog.visible = true
	for i in range(12):
		add_clean_plate()
	Autoload.popularity_progress_bar = $UI/ProgressBar
	Autoload.order_zone = $OrderZone
	Autoload.great_sound = $Great
	Autoload.bad_sound = $Bad
	Autoload.babyphone = $BabyPhone
	Autoload.baby = $Baby
	baby = Autoload.baby

	randomize()
	spawn_new_customer()

func _process(delta):
	move_camera()

func _physics_process(delta):
	check_for_orders()
	check_for_dishes()
	check_for_dirty_plate()
	check_for_holding_plate()
	check_for_serving_plate()
	check_for_dishwasher()
	check_for_taking_baby()

	if Input.is_action_pressed("quit"):
		get_tree().quit()

	if Input.is_action_just_released("switch_camera"):
		$Camera.current = !$Camera.current

	if $UI/ProgressBar.value == 0 or baby.dead:
		$UI/GameOver.visible = true
		get_tree().paused = true

func check_for_orders():
	if Input.is_action_just_released("action") and not $Customers.get_children().empty() and not lock_order:
		if $OrderZone.overlaps_body($Player):
			for customer in $Customers.get_children():
				if $OrderZone.overlaps_body(customer):
					display_order_popup()
					$Blip.play()
					lock_order = true
					return


func display_order_popup():
	var pos = $Camera.unproject_position($Customers.get_child(0).translation)
	pos.y -= 100

	$UI/OrderMenu.dialog_text = "Hi, I want a " + get_random_menu() + " menu please !"
	$UI/OrderMenu.set_position(pos)
	$UI/OrderMenu.visible = true

func check_for_dishes():
	if Input.is_action_just_released("action"):
		if $DishesZone.overlaps_body($Player):
			if $ReadyPlates.get_child_count() < 6:
				display_dishes_popup()
				$Blip.play()

func display_dishes_popup():
	$UI/DishesPopup.set_position(get_popup_position($Player.translation))
	$UI/DishesPopup.visible = true

func check_for_holding_plate():
	if Input.is_action_just_released("action"):
		for plate in $ReadyPlates.get_children():
			if $Player.holding_plate == null and plate.get_node("Area").overlaps_body($Player):
				if $Player.dirty_plate_count == 0:
					$ReadyPlates.remove_child(plate)
					$Player.take_ready_plate(plate)
					plate.stop_ready_timer()
					$Blip.play()
				return

func check_for_dirty_plate():
	if Input.is_action_just_released("action"):
		# on tables
		for table in $Tables.get_children():
			if table is Area:
				var plate = table.get_node("PlateStatic")
				if plate != null && plate.is_dirty() and $Player.holding_plate == null and plate.get_node("Area").overlaps_body($Player):
					$Player.take_dirty_plate(plate)
					$Blip.play()
					table.is_free = true
					return
		# on ready bar
		for plate in $ReadyPlates.get_children():
			if plate.is_dirty() and $Player.dirty_plate_count < 4 and $Player.holding_plate == null and plate.get_node("Area").overlaps_body($Player):
				$Player.take_dirty_plate(plate)
				$Blip.play()
				return

func check_for_serving_plate():
	if Input.is_action_just_released("action") and $Player.holding_plate != null:
		for table_area in $Tables.get_children():
			if table_area is Area and table_area.overlaps_body($Player):
				for customers in $TableCustomers.get_children():
					print("customer overlap " + table_area.name + " " + str(table_area.overlaps_body(customers)))
					if table_area.overlaps_body(customers):
						var plate = $Player.holding_plate
						plate.get_node("Area/CollisionShape").shape.extents.z = 4.2
						$Player.remove_plate()
						customers.served(plate.type)
						plate.translation = table_area.get_node("PlatePosition").translation
						table_area.add_child(plate)
						plate.start_dirty_timer()
						$Blip.play()

func check_for_dishwasher():
	if Input.is_action_just_released("action"):
		if $DishwasherZone.overlaps_body($Player):
			if $Player.dirty_plate_count > 0:
				$Player.remove_dirty_plate()
				start_timer_for_cleaned()
				$Blip.play()

func check_for_taking_baby():
	if Input.is_action_just_released("action") and baby.is_escaped:
		if baby.is_holded:
			if $CradleArea.overlaps_body($Player):
				$Player.remove_child(baby)
				add_child(baby)
				baby.put_in_bed($BabyCraddlePosition.translation)
		elif baby.get_node("TakeArea").overlaps_body($Player):
			print("take baby")
			var baby = $Baby
			remove_child(baby)
			$Player.hold_baby(baby)

func start_timer_for_cleaned():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2
	timer.one_shot = true
	timer.connect("timeout", self, "_on_Dishwasher_finished") # BaseButton signal
	timer.start()

func _on_Dishwasher_finished():
	add_clean_plate()

func add_clean_plate():
	var plate = plate_clean_scn.instance()
	if randi() % 2 == 0:
		plate.translate(Vector3.BACK * 0.5)
	$CleanPlates.add_child(plate)

func _on_OrderMenu_confirmed():
	var customer = $Customers.get_children().pop_front()
	customer.ordered_id_menu = next_menu
	for table in $Tables.get_children():
		if table.is_free:
			table.is_free = false
			customer.table_for_eat = table
			customer.start_dish_timer()
			lock_order = false
			customer.path = $Navigation.get_simple_path(customer.global_transform.origin, customer.table_for_eat.translation)
			$Customers.remove_child(customer)
			$TableCustomers.add_child(customer)
			return

func _on_DishesPopup_id_pressed(menu_id):
	var plate_to_remove = $CleanPlates.get_child(0)
	if plate_to_remove != null:
		plate_to_remove.queue_free()

		var plate = plate_scn.instance()
		$ReadyPlates.add_child(plate)
		plate.set_type(menu_id)
		plate.get_node("Particles").emitting = true
		$Blip.play()

		var pos = 0
		for clean_plate in $ReadyPlates.get_children():
			clean_plate.translation = Vector3(0, 0, pos*1)
			pos += 1


################
# Utils functions
#################

func get_popup_position(vector):
	return $Camera.unproject_position(vector)


func get_random_menu():
	next_menu = randi() % 3
	if next_menu == 0:
		return "Red"
	elif next_menu == 1:
		return "Green"
	elif next_menu == 2:
		return "Blue"

func _on_DoorZoneAppart_body_exited(body):
	if not $DoorZone.overlaps_body($Player):
		move_to_apartment = true

func _on_DoorZoneRestaurant_body_exited(body):
	if not $DoorZone.overlaps_body($Player):
		move_to_apartment = false

func move_camera():
	if move_to_apartment:
		$Camera.translation = $Camera.translation.linear_interpolate($CameraPositionApartment.translation, 0.05)
		$World/Apartment/Mesh.mesh.surface_get_material(0).params_blend_mode = 0
		$World/Restaurant/Mesh.mesh.surface_get_material(0).params_blend_mode = 1
	else:
		$Camera.translation = $Camera.translation.linear_interpolate($CameraPositionRestaurant.translation, 0.05)
		$World/Restaurant/Mesh.mesh.surface_get_material(0).params_blend_mode = 0
		$World/Apartment/Mesh.mesh.surface_get_material(0).params_blend_mode = 1

func _on_CustomerSpawner_timeout():
	spawn_new_customer()

func spawn_new_customer():
	var customer = customer_scn.instance()
	customer.translation = $SpawnCustomerPosition.translation - Vector3(2 * $Customers.get_child_count(), 0, 0)
	$Customers.add_child(customer)

func _on_TutoDialog5_confirmed():
	get_tree().paused = false

func _on_WelcomeDialog_hide():
	$UI/TutoDialog1.set_position(get_popup_position($PopupPos/Pos1.translation))
	$UI/TutoDialog1.visible = true

func _on_TutoDialog1_hide():
	$UI/TutoDialog2.set_position(get_popup_position($PopupPos/Pos2.translation))
	$UI/TutoDialog2.visible = true

func _on_TutoDialog2_hide():
	$UI/TutoDialog3.set_position(get_popup_position($PopupPos/Pos3.translation))
	$UI/TutoDialog3.visible = true

func _on_TutoDialog3_hide():
	$UI/TutoDialog4.set_position(get_popup_position($PopupPos/Pos4.translation))
	$UI/TutoDialog4.visible = true

func _on_TutoDialog4_hide():
	$UI/TutoDialog5.set_position(get_popup_position($PopupPos/Pos5.translation))
	$UI/TutoDialog5.visible = true

func _on_TutoDialog5_hide():
	$UI/TutoDialog6.set_position(get_popup_position($PopupPos/Pos6.translation))
	$UI/TutoDialog6.visible = true

func _on_GameOver_hide():
	get_tree().reload_current_scene()


func _on_TutoDialog6_hide():
	get_tree().paused = false
