extends PlayerState

@export var idle_state: PlayerState
@export var locomotion_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState

func process_physics(delta: float) -> PlayerState:
	if parent._blend_walk:
		return locomotion_state
	
	if parent._is_starting_jump:
		return jump_state
	elif !parent.is_on_floor():
		return fall_state
	
	if parent._raw_input.length() == 0:
		return idle_state
	
	return null
