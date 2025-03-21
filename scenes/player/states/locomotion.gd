extends PlayerState

@export var idle_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState
@export var blend_space_path : String

var blend_position := Vector2.ZERO
var rotation_speed: float


func process_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("ui_focus_next"):
		parent._blend_walk = false
		return idle_state
	return null

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
	
	# Vira personagem para direçao da camera quando detecta input de movimento
	if parent._raw_input:
		skin.global_rotation.y = lerp_angle(skin.rotation.y, camera_pivot.rotation.y, rotation_speed * delta)

	return null
