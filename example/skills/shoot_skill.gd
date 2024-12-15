class_name ShootSkill extends ExampleSkill

@export var bonus_damage_percent: float

func use(targets: Array[RpgCharacter]) -> void:
	super.use(targets)
	
	assert(targets.size() == 1)
	
	var target = targets.front()
	var damage = get_damage_amount()
	if target.get_status(&"slowed") or target.get_status(&"stunned"):
		damage += get_bonus_damage_amount()
	targets.front().modify_hp(-damage, self)
	user.end_turn()

func get_damage_amount() -> int:
	return floori(user.get_stat(&"attack").get_modified_value()) * tier

func get_bonus_damage_amount() -> int:
	return floori(bonus_damage_percent * get_damage_amount())
