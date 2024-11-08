class_name SlashSkill extends ExampleSkill

func _init(t: int = 1) -> void:
	super(&"slash", t)
	target_type = TargetType.ONE_ENEMY

func use(source: RpgCharacter, targets: Array[RpgCharacter]) -> void:
	super.use(source, targets)
	
	var damage = maxi(floori(source.get_stat(&"attack").base_value) + randi_range(-5, 5 * tier), 1)
	targets.front().modify_hp(-damage)
	source.end_turn()
