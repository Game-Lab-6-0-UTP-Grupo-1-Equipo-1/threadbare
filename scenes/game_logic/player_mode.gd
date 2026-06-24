# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
class_name PlayerMode
extends Node
## Set player to a single ability according to a mode.
##
## This is used to maintain the previous player modes behavior
## in the StoryQuests that were created before player abilities were introduced.
## Caution: previously gained abilities will be lost!
## Use player abilities instead.

## Modes used to enable the single ability, if any.
enum Mode {
	## Player has no abilities.
	COZY,
	## Player has ABILITY_A, usually mapped to the "repel" action.
	FIGHTING,
	## Player has ABILITY_B, usually mapped to the "grapple" action.
	HOOKING,
}
@export_file("*.tscn") var next_scene: String = ""
@export var mode: Mode = Mode.COZY:
	set = set_mode


func set_mode(new_mode: Mode) -> void:
	mode = new_mode
	GameState.clear_abilities()
	match mode:
		Mode.FIGHTING:
			GameState.set_ability(Enums.PlayerAbilities.ABILITY_A, true)
		Mode.HOOKING:
			GameState.set_ability(Enums.PlayerAbilities.ABILITY_B, true)


func _ready() -> void:
	set_mode(mode)


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneSwitcher.change_to_file_with_transition(next_scene)
