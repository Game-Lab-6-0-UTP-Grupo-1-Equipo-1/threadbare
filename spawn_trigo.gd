extends Area2D

@onready var escena_trigo = load("res://scenes/quests/story_quests/santuario_corrupto/3_sequence_puzzle/trigo.tscn")
@onready var marker = $"../Player/Marker"  
@export_file("*.tscn") var next_scene: String = ""
var bool_spawn = true
var random = RandomNumberGenerator.new()

func _ready() -> void:
	random.randomize()

func _process(delta: float) -> void:
	spawn()

func spawn():
	if bool_spawn:
		$Timer.start()
		bool_spawn = false
		var instancia_trigo = escena_trigo.instantiate()
		instancia_trigo.position = Vector2(
			marker.global_position.x + random.randi_range(1, 100),
			marker.global_position.y - random.randi_range(-10, 10)
		)
		add_child(instancia_trigo)

func _on_timer_timeout() -> void:
	bool_spawn = true


func _on_area_2d_body_entered_next_level(body: Node2D) -> void:
	if body.is_in_group("player"):
			SceneSwitcher.change_to_file_with_transition(next_scene)
