extends Powerup


func pickup():
	super()
	PlayerStats.missiles += 3


func _on_body_entered(body):
	if body.current_weapon_mode[0] == body.WeaponMode.BLASTER:
		super(body)
