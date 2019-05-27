extends Spatial



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var invOpen = false
	
	if (Input.is_action_just_pressed("toggle_inventory")):
		invOpen = !invOpen
		
	if (Input.is_action_pressed("hold_inventory")):
		invOpen = true
	else:
		invOpen = false
		
	if (invOpen):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		
	if (Input.is_action_just_pressed("ui_cancel")):
		get_tree().quit()
		
		
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
		
func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
