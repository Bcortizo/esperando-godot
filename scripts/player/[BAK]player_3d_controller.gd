extends CharacterBody3D
## Um controlador simples de personagens em 3ª pessoa
##
## Um controlador simples de personagens para jogos 3D em 3ª pessoa,
## programado com base em um tutorial do GDQuest.
##
## @tutorial(3D TUTORIAL: Make Smooth 3D Movement in Godot 4): https://youtu.be/JlgZtOFMdfc?si=WQpWJb364fhtfCjp

@export_group("Camera")
## Sensitividade do mouse.
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
## Velocidade do jogador.
@export var move_speed := 8.0
## Aceleração da velocidade.[br]
## Afeta quão rápido vira (desliza).
@export var acceleration := 20.0
## Velocidade de rotação da personagem.
@export var rotation_speed := 12.0
## Força do impulso do pulo
@export var jump_impulse := 7.0

@export_group("Animation")
## Velocidade da transição das animações.
@export var transition_speed := 2.0


@export_group("Inputs")
@export var move_forward := "ui_up"
@export var move_back := "ui_down"
@export var move_left := "ui_left"
@export var move_right := "ui_right"
@export var jump := "ui_accept"

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _blend_walk := false
var _blend_position := Vector2.ZERO
var _raw_input := Vector2.ZERO

@onready var _state_machine = $StateMachine
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %PlayerCamera
@onready var _skin: AnimationController = %SkeletonMage

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("ui_focus_next"):
		_blend_walk = !_blend_walk

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_in_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_in_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _process(delta: float) -> void:
	# Suavização das transições das animações do blendspace2D
	# Godot 3D - Basic Character Controller | Character Animation Tutorial: 5
	# https://www.youtube.com/watch?v=l4uWdObc4do
	var new_delta = _raw_input - _blend_position
	if (new_delta.length() > transition_speed * delta):
		new_delta = new_delta.normalized() * transition_speed * delta
	
	_blend_position += new_delta

func _physics_process(delta: float) -> void:
	#region Câmera
	# rotação vertical da câmera
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	
	# rotação horizontal da câmera
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	#endregion
	
	#region Movimento
	# pega vetor de entrada dos comandos de movimento
	var raw_input := Input.get_vector(move_left, move_right, move_forward, move_back)
	_raw_input = raw_input
	# pega referência dos eixos de movimento em relação à câmera
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	# gera o vetor de movimento pro plano horizontal e normaliza
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	# calcula velocidade da personagem, levando em conta a aceleração e aplica gravidade
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity - _gravity * delta
	
	# pulo
	var is_starting_jump := Input.is_action_just_pressed(jump) and is_on_floor()
	if is_starting_jump:
		velocity.y = jump_impulse
	
	# move personagem
	move_and_slide()
	
	# salva última direção movida
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	if _blend_walk:
		# Vira personagem para direçao da camera quando detecta input de movimento
		if raw_input:
			_skin.global_rotation.y = lerp_angle(_skin.rotation.y, _camera_pivot.rotation.y, rotation_speed * delta)
	else:
	# vira personagem na direção movida, interpolando linearmente o ângulo de rotação.
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	#endregion
	
	#region Animações
	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor():
		_skin.fall()
	elif is_on_floor():
		var ground_speed := velocity.length()
		if ground_speed > 0.0:
			if _blend_walk:
				_skin.locomotion()
			else:
				_skin.walking()
		else:
			_skin.idle()
	#endregion
