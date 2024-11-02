class_name EneygyShield
extends Area2D

@export var max_sp: int = 100
signal max_sp_changed(new_max)
var sp : int = max_sp : set = set_sp
signal sp_changed(new_value)

var recovering: bool = false
@export var recovering_speed: float = 1.5
signal recovering_speed_changed(new_speed)

@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var collisionShape: CollisionShape2D = get_node("CollisionShape2D")
@onready var animationPlayer = $AnimationPlayer
@onready var recoverTimer: Timer = get_node("RecoverTimer")
@onready var progress_bar = $ProgressBar

var new_tween : Tween

var is_invincible = false :
	set(value):
		is_invincible = value
		disable.call_deferred(value)


func _process(delta):
	#print("get_parent().scale.y: ", get_parent().scale.y)
	scale.x = get_parent().scale.y


func disable(value):
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = value


func set_sp(new_value: int) -> void:
	sp = clamp(new_value, 0, max_sp)
	emit_signal("sp_changed", sp)


func _ready() -> void:
	#print("EneygyShield _ready()")
	collisionShape.disabled = false
	
	#get_parent().connect("_on_hurtbox_hurt", _on_parent_receive_damage)
	emit_signal("recovering_speed_changed", recovering_speed)
	
	animationPlayer.play("2")


func take_hit(hitbox, damage) -> void:
	#print("EneygyShield, take_hit()")
	#print("EneygyShield, self.sp: ", self.sp)
	#print("get_parent().hurtbox.is_invincible: ", get_parent().hurtbox.is_invincible)
	
	recovering = false
	self.sp -= damage * 10.0
	set_sp(self.sp)
	
	var tween := get_tree().create_tween()
	new_tween = tween
	var new_sp = float(self.sp) / float(max_sp) * 100.0
	progress_bar.value = new_sp
	new_tween.tween_property(progress_bar, "value", new_sp, 0.1)
	new_tween.play()
	
	#print("")
	
	if self.sp != 0:
		get_parent().hurtbox.is_invincible = true
	
	if self.sp == 0:
		animationPlayer.play("3")
		await animationPlayer.animation_finished
		collisionShape.disabled = true
		get_parent().hurtbox.is_invincible = false
		queue_free()
	elif self.sp == 50:
		sprite.frame = 160
	elif self.sp == 40:
		sprite.frame = 163
	elif self.sp == 30:
		sprite.frame = 166
	elif self.sp == 20:
		sprite.frame = 169
	elif self.sp == 10:
		sprite.frame = 172
	else:
		animationPlayer.play("1")
		
	#recoverTimer.start()
	Sound.play(Sound.hurt)
	
	
func _on_recover_timer_timeout() -> void:
	recovering = true
	while recovering:
		#self.sp += 1
		if sp == max_sp:
			recovering = false
		
		await(get_tree().create_timer(recovering_speed))


func _on_parent_receive_damage() -> void:
	recovering = false
	recoverTimer.start()


func _on_max_sp_changed(new_max: Variant) -> void:
	pass # Replace with function body.
