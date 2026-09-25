extends Control

signal return_selected()
signal retry_selected()

@onready var options_menu: Control = $OptionsMenu


func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause_menu") && !options_menu.visible:
		visible = !visible
		get_tree().paused = visible


func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_restart_button_pressed() -> void:
	hide()
	get_tree().paused = false
	retry_selected.emit()


func _on_return_buttom_pressed() -> void:
	get_tree().paused = false
	return_selected.emit()
