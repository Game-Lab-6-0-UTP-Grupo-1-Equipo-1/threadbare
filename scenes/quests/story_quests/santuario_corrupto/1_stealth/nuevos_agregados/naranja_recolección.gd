# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends Area2D

var recolectada: bool = false   # Evita doble recolección
@onready var sound_player: AudioStreamPlayer2D = $SoundPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if recolectada:
		return
	if body.is_in_group("player"):
		recolectada=true
		GameManager.recolectar_naranja() #incrementa contador
		sound_player.play()
		await get_tree().create_timer(0.35).timeout
		queue_free()
	
