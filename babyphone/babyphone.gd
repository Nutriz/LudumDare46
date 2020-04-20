extends Spatial

func _ready():
	pass

func start_alert():
	$Alert.visible = true
	$AlertSound.play()

func stop_alert():
	$Alert.visible = false
	$AlertSound.stop()
