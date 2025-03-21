extends Node

## Define estado inicial
@export var starting_state: PlayerState
@export var animation_tree: AnimationTree
@export var animation_machine_path: String
@export var camera_pivot: Node3D
@export var skin: Node3D

var current_state := starting_state

@onready var anim_machine: AnimationNodeStateMachinePlayback = animation_tree.get(animation_machine_path)

# Inicializa a maquina de estados, passando as referencias necessarias para herdeiros
func init(parent: CharacterBody3D):
	for child in get_children():
		child.parent = parent
		child.animation_tree = animation_tree
		child.anim_machine = anim_machine
		child.skin = skin
		child.camera_pivot = camera_pivot
	
	# inicia o estado inicial
	change_state(starting_state)

# muda para o novo estado, executando logica de saida do antigo e de entrada do novo
func change_state(new_state: PlayerState) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

# passa funçoes para Player3D executar, e muda de estado se preciso
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
