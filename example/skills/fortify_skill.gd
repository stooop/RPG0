class_name FortifySkill extends ExampleSkill

func use(targets: Array[RpgCharacter]) -> void:
	super.use(targets)
	
	for target in targets:
		var spirit_shield = target.get_capability(&"spirit_shield")
		if spirit_shield:
			spirit_shield.current_value += get_shield_amount()
			target.add_new_status(&"spirit_shielded")
	
	user.end_turn()

func get_shield_amount() -> int:
	return 10
