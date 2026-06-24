# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends CanvasLayer

@onready var story_quest_progress: PanelContainer = %StoryQuestProgress
@onready var label = $Label 

func _ready()->void:
	# Ocultar el panel de progreso de la misión
	if story_quest_progress:
		story_quest_progress.visible = false
		
	# conectar la señal de actualización del GameManager
	GameManager.naranjas_actualizadas.connect(_actualizar_label)
	_actualizar_label(GameManager.naranjas_recolectadas)

func _exit_tree() ->void:
	# al salir de la escena, desconecta la señal para evitar llamadas a un nodo destruido
	if GameManager.naranjas_actualizadas.is_connected(_actualizar_label):
		GameManager.naranjas_actualizadas.disconnect(_actualizar_label)
		
func _actualizar_label(cantidad: int)->void:
	# Verifica que el nodo Label exista antes de usarlo
	if label:
		label.text = str(cantidad) + " / " + str(GameManager.naranjas_necesarias)
