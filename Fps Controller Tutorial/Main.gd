extends Spatial

var invOpen : bool # is the inventory open?

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	invOpen = false

func _process(delta):
	
	if (Input.is_action_just_pressed("toggle_inventory")):
		invOpen = !invOpen
		
	if (Input.is_action_just_pressed("hold_inventory")):
		invOpen = true
	elif (Input.is_action_just_released("hold_inventory")):
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
