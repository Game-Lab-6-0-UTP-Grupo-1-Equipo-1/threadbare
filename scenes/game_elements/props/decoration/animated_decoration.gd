# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
extends Area2D

const DEFAULT_SPRITE_FRAME: SpriteFrames = preload("uid://dm5jcge3jb7p1")

@export var sprite_frames: SpriteFrames = DEFAULT_SPRITE_FRAME:
	set = _set_sprite_frames

@export var factor_ralentizacion: float 
@export var duracion_ralentizacion: float 
@export var tiempo_autoeliminar: float

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var jugador = null
var velocidad_original = 0.0
var timer_ralentizacion = null
var timer_auto = null  #guardamos referencia al timer auto

func _set_sprite_frames(new_sprite_frames: SpriteFrames) -> void:
	sprite_frames = new_sprite_frames
	if not is_node_ready():
		return
	if new_sprite_frames == null:
		new_sprite_frames = DEFAULT_SPRITE_FRAME
	animated_sprite_2d.sprite_frames = new_sprite_frames
	animated_sprite_2d.play(animated_sprite_2d.animation)

func _ready():
	# autoeliminarse
	timer_auto = Timer.new()  
	timer_auto.wait_time = tiempo_autoeliminar 
	timer_auto.one_shot = true
	add_child(timer_auto)
	timer_auto.timeout.connect(queue_free)
	timer_auto.start()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.get_meta("ralentizado", false):
			return 
		jugador = body
		
		# cancelar autoeliminación para que no se elimine antes
		if timer_auto:
			timer_auto.stop()
			timer_auto.queue_free()
			timer_auto = null
		
		if velocidad_original == 0.0:
			velocidad_original = jugador.speeds.walk_speed
		
		# usamos factor_ralentizacion
		jugador.speeds.walk_speed = velocidad_original * factor_ralentizacion
		jugador.speeds.run_speed = velocidad_original * factor_ralentizacion
		jugador.input_walk_behavior.speeds = jugador.speeds
		
		# creamos timer para restaurar y eliminar en una sola función
		timer_ralentizacion = Timer.new()
		timer_ralentizacion.one_shot = true
		add_child(timer_ralentizacion)
		timer_ralentizacion.timeout.connect(_restaurar_y_eliminar)  # Solo una conexión
		timer_ralentizacion.wait_time = duracion_ralentizacion  # usamos variable exportada
		timer_ralentizacion.start()
		
		jugador.set_meta("ralentizado", true)

#  función que restaura y elimina
func _restaurar_y_eliminar():
	if jugador and velocidad_original > 0:
		jugador.speeds.walk_speed = velocidad_original
		jugador.speeds.run_speed = velocidad_original
		jugador.input_walk_behavior.speeds = jugador.speeds
		velocidad_original = 0.0
		
		if jugador.has_meta("ralentizado"):
			jugador.remove_meta("ralentizado")
	queue_free()
