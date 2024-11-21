class_name SlashSkill extends ExampleSkill

func use(targets: Array[RpgCharacter]) -> void:
	super.use(targets)
	
	assert(targets.size() == 1)
	
	var damage = randi_range(get_damage_floor(), get_damage_ceiling())
	targets.front().modify_hp(-damage)
	user.end_turn()

func get_damage_floor() -> int:
	return maxi(floori(user.get_stat(&"attack").get_modified_value()) - 5, 1)

func get_damage_ceiling() -> int:
	return floori(user.get_stat(&"attack").get_modified_value()) + (5 * tier)
