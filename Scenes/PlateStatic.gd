extends StaticBody

var type

func set_type(id_menu):
	type = id_menu

	if type == 0:
		$MeshRed.visible = true
	elif type == 1:
		$MeshGreen.visible = true
	elif type == 2:
		$MeshBlue.visible = true

	print("start ready timer")
	$ReadyDirtyTimer.start()

func start_dirty_timer():
	$DirtyTimer.start()

func stop_ready_timer():
	$ReadyDirtyTimer.stop()

func _on_ReadyDirtyTimer_timeout():
	set_dirty()

func _on_DirtyPlate_timeout():
	set_dirty()

func is_dirty():
	return $MeshDirty.visible

func set_dirty():
	$MeshRed.visible = false
	$MeshGreen.visible = false
	$MeshBlue.visible = false
	$MeshDirty.visible = true
