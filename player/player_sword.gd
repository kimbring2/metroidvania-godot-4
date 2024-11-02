extends Node2D

@onready var sword_sprite = $Sword

func _process(_delta):
	var local_mouse_position = get_local_mouse_position()
	var mouseLocFromPlayer = get_global_mouse_position() - get_parent().position
	
	'''
	var parent_current_anim = get_parent().get_node("AnimationPlayer").current_animation
	var parent_velocity = get_parent().velocity
	print("parent_current_anim: ", parent_current_anim)
	print("sword_sprite.position.x: ", sword_sprite.position.x)
	print("sword_sprite.position.y: ", sword_sprite.position.y)
	print("")
	#print("mouseLocFromPlayer.x: ", mouseLocFromPlayer.x)
	#print("parent_velocity: ", parent_velocity)
	if mouseLocFromPlayer.x < 0:
		if parent_current_anim == 'idle':
			sword_sprite.position.x = 100
			sword_sprite.position.y = 0
		elif parent_current_anim == 'run':
			if parent_velocity[0] >= 0:
				sword_sprite.position.x = -100
				sword_sprite.position.y = 0
			else:
				sword_sprite.position.x = 100
				sword_sprite.position.y = 0
	else:
		sword_sprite.position.x = 0
		sword_sprite.position.y = 0
	'''
	#sword_sprite.rotation = get_local_mouse_position().angle()
	pass


func swing_sword():
	pass
