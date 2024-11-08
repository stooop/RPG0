class_name ExampleCharacter extends RpgCharacter

func add_default_stats() -> ExampleCharacter:
	add_new_stat(&"speed")
	add_new_stat(&"max_health")
	add_new_stat(&"attack")
	return self

func add_default_combat_resources() -> ExampleCharacter:
	add_new_combat_resource(&"health", get_stat(&"max_health").base_value) # TODO: Use modified value
	return self
