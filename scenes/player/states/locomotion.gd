extends PlayerState

@export var idle_state: PlayerState
@export var walking_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState
@export var blend_space_path : String

var blend_position := Vector2.ZERO
var rotation_speed: float

func process_frame(delta: float) -> PlayerState:
	# Suavização das transições das animações do blendspace2D
	# Godot 3D - Basic Character Controller | Character Animation Tutorial: 5
	# https://www.youtube.com/watch?v=l4uWdObc4do
	var new_delta = parent._raw_input - blend_position
	if (new_delta.length() > parent.transition_speed * delta):
		new_delta = new_delta.normalized() * parent.transition_speed * delta
	blend_position += new_delta
	
	return null

func process_physics(delta: float) -> PlayerState:
	rotation_speed = parent.rotation_speed
	
	animation_tree.set(blend_space_path, blend_position)
	
	# Vira personagem para direção da câmera quando detecta input de movimento
	if parent._raw_input:
		skin.global_rotation.y = lerp_angle(skin.rotation.y, camera_pivot.rotation.y, rotation_speed * delta)
	
	if parent._is_starting_jump:
		return jump_state
	elif !parent.is_on_floor():
		return fall_state
	
	if !parent._blend_walk:
		return idle_state
	
	return null
