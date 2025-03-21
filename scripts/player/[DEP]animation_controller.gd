class_name AnimationController extends Node3D

@onready var player = self.owner
@export var animation_tree: AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var walk_blend_position_path = "parameters/Locomotion/blend_position"

func idle() -> void:
	state_machine.travel("Idle")

func walking() -> void:
	state_machine.travel("Walking")

func fall() -> void:
	state_machine.travel("Fall")

func jump() -> void:
	state_machine.travel("Jump_Start")

func locomotion() -> void:
	state_machine.travel("Locomotion")
	animation_tree.set(walk_blend_position_path, player._blend_position)
