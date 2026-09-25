@tool
extends Node

@onready var input: Button = %Input
@onready var action: Label = %Action

@export var action_id: String

@export var action_name: String:
	set(value):
		action_name = value
		if Engine.is_editor_hint() and is_node_ready() and has_node("%Action"):
			action.text = value


func _ready() -> void: 
	set_process_input(false)
	action.text = action_name
	
	if Engine.is_editor_hint():
		input.text = action_name if action_name != "" else action_id
		return

	if InputMap.has_action(action_id):
		var events: Array[InputEvent] = InputMap.action_get_events(action_id)
		if events.size() > 0:
			_set_event(events[0])
		else:
			input.text = "None"
	else:
		input.text = action_id


func _input(event: InputEvent) -> void:
	if event.is_pressed() and not (event is InputEventMouseMotion):
		InputMap.action_erase_events(action_id)
		InputMap.action_add_event(action_id, event)
		_set_event(event)
		set_process_input(false)
		get_viewport().set_input_as_handled()
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(input):
			input.grab_focus()


func _set_event(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				input.text = "Left Mouse Button"
			MOUSE_BUTTON_RIGHT:
				input.text = "Right Mouse Button"
			MOUSE_BUTTON_MIDDLE:
				input.text = "Middle Mouse Button"
			MOUSE_BUTTON_WHEEL_UP:
				input.text = "Mouse Wheel Up"
			MOUSE_BUTTON_WHEEL_DOWN:
				input.text = "Mouse Wheel Down"
			_:
				var t: String = event.as_text().replace(" (Physical)", "").strip_edges()
				input.text = t if t != "" else str(event.button_index)
	elif event is InputEventKey:
		var key_str: String = ""
		if event.keycode != KEY_NONE:
			key_str = OS.get_keycode_string(event.keycode)
		elif event.physical_keycode != KEY_NONE:
			key_str = OS.get_keycode_string(event.physical_keycode)
		else:
			key_str = event.as_text().replace(" (Physical)", "").strip_edges()
		input.text = key_str
	else:
		input.text = event.as_text().replace(" (Physical)", "").strip_edges()


func _on_input_pressed() -> void:
	set_process_input(true)
	input.text = "..."
	input.release_focus()
