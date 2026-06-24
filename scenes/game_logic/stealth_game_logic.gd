# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
class_name StealthGameLogic
extends Node

@export_file("*.tscn") var next_scene: String = ""

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for guard: Guard in get_tree().get_nodes_in_group(&"guard_enemy"):
		guard.player_detected.connect(self._on_player_detected)

func _on_player_detected(player: Node2D) -> void:
	if player.has_method("defeat"):
		GameManager.naranjas_recolectadas = 0
		player.defeat()
	else:
		push_warning("Detected node does not have defeat() method", player)

#Para cambiar la escena
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneSwitcher.change_to_file_with_transition(next_scene)
