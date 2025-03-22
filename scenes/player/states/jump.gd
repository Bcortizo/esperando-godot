extends PlayerState

@export var fall_state: PlayerState
@export var idle_state: PlayerState
@export var locomotion_state: PlayerState

func process_physics(delta: float) -> PlayerState:
	if parent.is_on_floor():
		if parent._blend_walk:
			return locomotion_state
		else:
			return idle_state
	elif parent.velocity.y > 0:
		return fall_state
	return null
