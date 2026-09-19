extends PlayerState

@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.18
@export var vertical_dash_multiplier: float = 0.65

var current_dash_time: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO


func enter() -> void:
	current_dash_time = dash_duration
	character.can_dash = false # Consumimos el dash disponible
	
	# Obtenemos la dirección del vector según las teclas de movimiento presionadas
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis(&"move_left", &"move_right")
	
	var up: float = -1.0 if (Input.is_action_pressed(&"jump") or Input.is_action_pressed(&"move_up")) else 0.0
	var down: float = 1.0 if (Input.is_action_pressed(&"move_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) else 0.0
	input_dir.y = (up + down) * vertical_dash_multiplier
	
	# Si hay dirección presionada (horizontal, vertical o diagonal), la normalizamos
	if input_dir != Vector2.ZERO:
		dash_direction = input_dir.normalized()
	else:
		# Si no se presiona ninguna dirección, dashea horizontal hacia donde mira el personaje
		dash_direction = Vector2.LEFT if character.body_pivot.scale.x < 0 else Vector2.RIGHT
	
	# Girar el sprite si hay componente horizontal
	if dash_direction.x != 0.0:
		character.body_pivot.scale.x = 1 - 2 * float(dash_direction.x < 0)
	
	character.velocity = dash_direction * dash_speed
	character._play_animation(&"jump")


func exit() -> void:
	current_dash_time = 0.0
	# Si salimos del dash con velocidad vertical hacia arriba, la suavizamos para no salir disparados
	if character.velocity.y < 0:
		character.velocity.y *= 0.2
	character.velocity.x = clamp(character.velocity.x, -character.h_speed_limit, character.h_speed_limit)


func handle_input(_event: InputEvent) -> void:
	return


func update(delta: float) -> void:
	character._handle_weapon_actions()
	
	current_dash_time -= delta
	character.velocity = dash_direction * dash_speed
	character.move_and_slide()
	
	if current_dash_time <= 0.0:
		if character.is_on_floor_raycasted():
			character.can_dash = true
			if Input.is_action_pressed(&"move_left") or Input.is_action_pressed(&"move_right"):
				finished.emit(&"walk")
			else:
				finished.emit(&"idle")
		else:
			finished.emit(&"jump")


func _on_animation_finished(_anim_name: StringName) -> void:
	return


func handle_event(event: StringName, value = null) -> void:
	match event:
		&"hit":
			character._handle_hit(value)
			if character.dead:
				finished.emit(&"dead")
