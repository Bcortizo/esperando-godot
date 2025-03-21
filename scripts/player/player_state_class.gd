class_name PlayerState extends Node
## Classe para os estados que o jogador pode assumir no jogo.

## Nome do estado
@export var state_name: String

var parent: CharacterBody3D
var animation_tree: AnimationTree
var anim_machine: AnimationNodeStateMachinePlayback
var skin: Node3D
var camera_pivot: Node3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func enter() -> void:
	anim_machine.travel(state_name)
	parent._can_look = true
	parent._can_move = true
	print("Entering state: [" + state_name + "]")

func exit() -> void:
	pass

func process_input(event: InputEvent) -> PlayerState:
	return null

func process_frame(delta: float) -> PlayerState:
	return null

func process_physics(delta: float) -> PlayerState:
	return null
