extends ProgressBar

var percentage_per_sp: float = 0.0
var speed: float = 0.0
#var tween = create_tween()
#var tween_callable_spawn_unit = Callable(self, "_tween_completed")


func _enter_tree() -> void:
	#print("_enter_tree()")
	#hide()
	pass


func _on_energy_shield_sp_changed(new_value: int) -> void:
	#print("_on_energy_shield_sp_changed()")
	#print(new_value)
	#tween.stop()
	#tween = get_tree().create_tween()
	#show()
	#new_tween.tween_property(unit_progress_bar, "value", 100.0, 3)
	#tween.interpolate_value(value, new_value * percentage_per_sp - value, speed / 2.0, speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	#tween.play()
	#tween.finished.connect(tween_callable_spawn_unit)
	pass


func _on_energy_shield_recovering_speed_changed(new_speed: float) -> void:
	speed = new_speed


func _on_energy_shield_max_sp_changed(new_max: int) -> void:
	percentage_per_sp = round(100.0 / new_max)


func _tween_completed():
	hide()
