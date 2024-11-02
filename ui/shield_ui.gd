extends HBoxContainer

@onready var label = $Label


func _ready():
	update_shields_label()
	PlayerStats.shields_changed.connect(update_shields_label)


func update_shields_label():
	visible = PlayerStats.shields > 0
	label.text = str(PlayerStats.shields)
