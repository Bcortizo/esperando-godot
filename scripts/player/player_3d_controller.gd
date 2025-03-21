class_name PlayerController extends CharacterBody3D
## Um controlador simples de personagens em 3ª pessoa
##
## Um controlador simples de personagens para jogos 3D em 3ª pessoa,
## programado com base no tutorial do GDQuest do link abaixo.
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
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _blend_walk := false
var _raw_input := Vector2.ZERO
var _can_move := true
var _can_look := true

@onready var _state_machine = $StateMachine
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %PlayerCamera
@onready var _skin: Node3D = %SkeletonMage

func _ready():
	_state_machine.init(self)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:	
	var is_camera_in_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_in_motion and _can_look:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
	
	_state_machine.process_input(event)

func _process(delta: float) -> void:
	_state_machine.process_frame(delta)

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
	_raw_input = Input.get_vector(move_left, move_right, move_forward, move_back)
	# pega referência dos eixos de movimento em relação à câmera
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	# gera o vetor de movimento pro plano horizontal e normaliza
	var move_direction := forward * _raw_input.y + right * _raw_input.x
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
	if _can_move:
		move_and_slide()
	
	if !_blend_walk:
		# salva última direção movida
		if move_direction.length() > 0.2:
			_last_movement_direction = move_direction
		# vira personagem na direção movida, interpolando linearmente o ângulo de rotação.
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	#endregion
	
	_state_machine.process_physics(delta)
	
	#region Animações
	#if is_starting_jump:
		#_skin.jump()
	#elif not is_on_floor():
		#_skin.fall()
	#elif is_on_floor():
		#var ground_speed := velocity.length()
		#if ground_speed > 0.0:
			#if _blend_walk:
				#_skin.locomotion()
			#else:
				#_skin.walking()
		#else:
			#_skin.idle()
	#endregion
