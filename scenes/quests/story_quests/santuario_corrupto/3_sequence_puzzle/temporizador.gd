extends Node

@export var tiempo_limite: float
@export var autostart: bool = false   
@onready var cinematic = $"../../Cinematic"

@onready var timer: Timer = $"../../Timer"
@onready var label: Label = $"../../Label"

signal tiempo_terminado

func temporizador():
	var time_left = timer.time_left
	var minuto = floor(time_left / 60)
	var segundo = int(time_left) % 60
	return [minuto, segundo]

func reset_and_start() -> void:
	timer.stop()
	start()

func start() -> void:
	if label:
		label.visible = true
	timer.start()

func stop() -> void:
	timer.stop()
	if label:
		label.visible = false

func _ready() -> void:
	timer.wait_time = tiempo_limite
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	if cinematic:
		cinematic.cinematic_finished.connect(_on_cinematic_finished)
	
	else:
		
		if autostart:
			start()

func _on_cinematic_finished() -> void:
	start()   #comienza el temmporizador

func _process(delta):
	if label and timer and timer.time_left > 0:
		label.text = "%02d:%02d" % temporizador()
	elif label and timer and timer.time_left <= 0:
		label.text = "00:00"

func _on_timer_timeout() -> void:
	tiempo_terminado.emit()
	get_tree().reload_current_scene()
