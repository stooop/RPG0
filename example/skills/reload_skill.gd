class_name ReloadSkill extends ExampleSkill

func use(targets: Array[RpgCharacter]) -> void:
	super(targets)
	
	assert(targets.size() == 1 and targets.front() == user)
	user.get_capability(&"ammo").reset()
	
	user.end_turn()

func can_use() -> bool:
	var ammo = user.get_capability(&"ammo")
	assert(ammo)
	return super() and !ammo.is_full()
