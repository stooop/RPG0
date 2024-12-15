class_name DrinkSkill extends ExampleSkill

func use(targets: Array[RpgCharacter]) -> void:
	super.use(targets)
	
	assert(targets.size() == 1 and targets.front() == user)
	user.get_capability(&"mana").current_value += get_restoration_amount()
	user.add_new_status(&"tipsy")
	
	user.end_turn()

func get_restoration_amount() -> int:
	return 30
