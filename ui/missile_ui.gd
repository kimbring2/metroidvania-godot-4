extends HBoxContainer

@onready var label = $Label


func _ready():
	#missiles_changed()
	update_missile_label()
	PlayerStats.missiles_changed.connect(update_missile_label)
	#PlayerStats._missiles_changed.connect(_missiles_changed)


func update_missile_label():
	visible = PlayerStats.missiles > 0
	label.text = str(PlayerStats.missiles)

#func _missiles_changed():
#	print("_missiles_changed()")
#	print("PlayerStats.missiles: ", PlayerStats.missiles)
#	visible = PlayerStats.missiles > 0
