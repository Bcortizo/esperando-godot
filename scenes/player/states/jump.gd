extends PlayerState

@export var fall_state: PlayerState

func process_physics(delta: float) -> PlayerState:
	if !parent.is_on_floor() and parent.velocity.y > 0:
		return fall_state
	return null
