# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
class_name FillGameLogic
extends Node
## Manages the logic of the fill-matching game.
##
## @tutorial: https://github.com/endlessm/threadbare/discussions/1323
##
## This is a piece of the fill-matching mechanic.
## [br][br]
## Grabs the label and optional color of each [FillingBarrel] that exist in the
## current scene, and assigns them as the allowed label/color of the [Projectile]
## that each [ThrowingEnemy] is allowed to throw.
## Each time a [FillingBarrel] is filled, perform the label/color assignment again
## so [ThrowingEnemy]s only throw projectiles that can increase the amount of
## the remaining barrels.
## [br][br]
## Also keep track of the completed [FillingBarrel]s and emit [signal goal_reached]
## when [member barrels_to_win] is reached.

## Emited when [member barrels_completed] reaches [member barrels_to_win].
signal goal_reached

@export_file("*.tscn") var next_scene: String = ""
## How many barrels to complete for winning.
@export var barrels_to_win: int = 1

## Whether to start the game logic automatically.
## If false, make sure to call [method start].
@export var autostart: bool = false

#Para el timer:
@onready var timer: Timer = $Timer

@onready var label=$Label

# Called when the node enters the scene tree for the first time.

func temporizador():
	var time_left = timer.time_left
	var minuto=floor(time_left/60)
	var segundo =int (time_left)%60
	return [minuto, segundo]

func reset_and_start() -> void:
	barrels_completed = 0
	timer.stop()
	start()  # Esto reinicia el timer y los enemigos
	
## Counter for the completed barrels.
var barrels_completed: int = 0

func _ready() -> void:	
	DamageManager.game_started.connect(_on_game_started)
	var filling_barrels: Array = get_tree().get_nodes_in_group("filling_barrels")
	barrels_to_win = clampi(barrels_to_win, 0, filling_barrels.size())
	for barrel: FillingBarrel in filling_barrels:
		barrel.completed.connect(_on_barrel_completed)
	timer.timeout.connect(_on_timer_timeout)
	
	if autostart:
		start()
		

## Update the allowed labels/colors and tell enemies to start.
func start() -> void:
	DamageManager.game_started.connect(_on_game_started)	
	_update_allowed_colors()  
	get_tree().call_group("throwing_enemy", "start")
	label.visible=true
	timer.start()   #comienza el temporizador

func _on_game_started() -> void:
	start()
#actualizacion del label que contiene el temporizador
func _process(delta):
	if label and timer:
		label.text = "%02d:%02d" % temporizador()
	

func _on_timer_timeout	() -> void:
	get_tree().call_group("throwing_enemy", "remove")
	get_tree().call_group("projectiles", "remove")
	
func _update_allowed_colors() -> void:
	var allowed_labels: Array[String] = []
	var color_per_label: Dictionary[String, Color]
	for filling_barrel: FillingBarrel in get_tree().get_nodes_in_group("filling_barrels"):
		if filling_barrel.is_queued_for_deletion():
			continue
		if filling_barrel.label not in allowed_labels:
			allowed_labels.append(filling_barrel.label)
			if not filling_barrel.color:
				continue
			color_per_label[filling_barrel.label] = filling_barrel.color
	for enemy: ThrowingEnemy in get_tree().get_nodes_in_group("throwing_enemy"):
		enemy.allowed_labels = allowed_labels
		enemy.color_per_label = color_per_label


func _on_barrel_completed() -> void:
	barrels_completed += 1
	_update_allowed_colors()
	if barrels_completed < barrels_to_win:
		return
	get_tree().call_group("throwing_enemy", "remove")
	get_tree().call_group("projectiles", "remove")
	goal_reached.emit()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneSwitcher.change_to_file_with_transition(next_scene)
