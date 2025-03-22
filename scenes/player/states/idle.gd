extends PlayerState

@export var locomotion_state: PlayerState
@export var walking_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState

func process_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("ui_down"):
		anim_machine.travel("Walking")
	return null

func process_physics(delta: float) -> PlayerState:
	if parent._is_starting_jump:
		return jump_state
	elif !parent.is_on_floor():
		return fall_state
	
	if parent._raw_input.length() != 0:
		return walking_state
	
	if parent._blend_walk:
		return locomotion_state
	return null
