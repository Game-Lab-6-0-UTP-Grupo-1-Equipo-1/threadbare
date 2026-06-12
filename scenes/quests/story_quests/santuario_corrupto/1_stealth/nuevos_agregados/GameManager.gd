# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends Node

var naranjas_recolectadas: int = 0
@export var naranjas_necesarias: int = 5

signal naranjas_actualizadas(cantidad_actual: int)
signal meta_alcanzada

func recolectar_naranja() -> void:
	naranjas_recolectadas += 1
	print("Progreso: ", naranjas_recolectadas, "/", naranjas_necesarias)
	naranjas_actualizadas.emit(naranjas_recolectadas)
	if naranjas_recolectadas >= naranjas_necesarias:
		meta_alcanzada.emit()
