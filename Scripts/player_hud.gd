extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel

var player_ref: Node = null

func _process(delta):
	if player_ref:
		health_bar.value = player_ref.health
		health_label.text = str(player_ref.health, "/", player_ref.max_health)

func _ready() -> void:
	player_ref = get_tree().get_current_scene().get_node("Pope")
