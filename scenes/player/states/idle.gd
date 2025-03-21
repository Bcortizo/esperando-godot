extends PlayerState

@export var locomotion_state: PlayerState
@export var walking_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState

func process_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("ui_focus_next"):
		parent._blend_walk = true
		return locomotion_state
	
	if event.is_action_pressed("ui_down"):
		anim_machine.travel("Walking")
	return null
