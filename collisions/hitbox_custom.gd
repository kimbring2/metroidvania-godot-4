class_name HitboxCustom
extends Area2D

@export var damage = 1
@onready var damage_timer = $DamageTimer
var _hurtbox_id_array = []

func _on_area_entered(hurtbox):
	#print("_on_area_entered()")
	#print("hurtbox: ", hurtbox)
	#print("")
	
	if _hurtbox_id_array.find(hurtbox.get_instance_id()) == -1:
		_hurtbox_id_array.append(hurtbox.get_instance_id())
		hurtbox.take_hit(self, damage)
		damage_timer.start()
	
	if (not hurtbox is Hurtbox) and (not hurtbox is EneygyShield) and (not hurtbox is PlayeryShield):
		return
		
		
func _on_area_exited(hurtbox):
	#print("_on_area_exited()")
	#print("hurtbox: ", hurtbox)
	#print("")
		
	if _hurtbox_id_array.find(hurtbox.get_instance_id()) != -1:
		_hurtbox_id_array.remove_at(_hurtbox_id_array.find(hurtbox.get_instance_id()))
		if _hurtbox_id_array.size() == 0:
			damage_timer.stop()
	
	
func _on_damage_timer_timeout() -> void:
	#print("_on_damage_timer_timeout")
	#print("_hurtbox_id_array: ", _hurtbox_id_array)
	
	for _hurtbox_id in _hurtbox_id_array:
		var hurtbox = instance_from_id(_hurtbox_id)
		hurtbox.take_hit(self, damage)
