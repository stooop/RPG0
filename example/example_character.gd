class_name ExampleCharacter extends RpgCharacter

func add_default_stats() -> ExampleCharacter:
	add_new_stat(&"speed")
	add_new_stat(&"max_health")
	add_new_stat(&"attack")
	return self

func add_default_capabilities() -> ExampleCharacter:
	add_new_capability(&"health", get_stat(&"max_health").get_modified_value())
	return self

func can_take_turn() -> bool:
	return super() and !get_status_effect(&"silenced")

func can_gain_action_points() -> bool:
	return super() and !get_status_effect(&"stunned")
