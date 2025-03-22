extends PlayerState

@export var idle_state: PlayerState
@export var walking_state: PlayerState
@export var locomotion_state: PlayerState

func process_physics(delta: float) -> PlayerState:
	if parent.is_on_floor():
		if parent._blend_walk:
			return locomotion_state
		elif parent._raw_input.length() > 0:
			return walking_state
		else:
			return idle_state
	return null
