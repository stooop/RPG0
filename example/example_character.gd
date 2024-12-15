class_name ExampleCharacter extends RpgCharacter

func add_default_stats() -> ExampleCharacter:
	add_new_stat(&"speed")
	add_new_stat(&"max_health")
	add_new_stat(&"max_mana")
	add_new_stat(&"attack")
	return self

func add_default_capabilities() -> ExampleCharacter:
	add_new_capability(&"health", get_stat(&"max_health").get_modified_value())
	add_new_capability(&"mana", get_stat(&"max_mana").get_modified_value())
	add_new_capability(&"spirit_shield", 0)
	return self

func can_take_turn() -> bool:
	return super() and !get_status(&"silenced") and !get_status(&"stunned")

func can_gain_action_points() -> bool:
	return super() and !get_status(&"stunned")

func modify_hp(amount: int, source: Variant = null) -> Variant:
	if is_dead():
		return super(0, source)
	
	var mitigated = 0
	if amount < 0:
		var spirit_shield = get_capability(&"spirit_shield")
		if spirit_shield and !spirit_shield.is_empty():
			mitigated = mini(absi(amount), spirit_shield.current_value)
			spirit_shield.current_value -= mitigated
	
	super(amount + mitigated, source)
	return amount # Returning the full amount including mitigated because the character was still damaged that amount
