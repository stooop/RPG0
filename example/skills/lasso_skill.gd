class_name LassoSkill extends ExampleSkill

func use(targets: Array[RpgCharacter]) -> void:
	super(targets)
	
	for target in targets:
		target.add_new_status(&"slowed", 1)
	
	user.end_turn()
