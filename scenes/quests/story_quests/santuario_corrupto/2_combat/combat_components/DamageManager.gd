# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends Node


# Called when the node enters the scene tree for the first time.

var impactos_jugador: int = 0
signal game_started

func _on_cinematic_finished() -> void:
	game_started.emit()
	
func registrar_impacto() -> void:
	impactos_jugador += 1
	print("Impactos al jugador: ", impactos_jugador)
	if impactos_jugador >= 3:
		reiniciar_juego()

func reiniciar_juego() -> void:
	print("Reiniciando juego...")
	impactos_jugador = 0  # reiniciar contador por si acaso
	GameState.intro_dialogue_shown = false
	SceneSwitcher.reload_with_transition(Transition.Effect.FADE, Transition.Effect.FADE)
	
