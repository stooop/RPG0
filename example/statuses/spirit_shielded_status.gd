class_name SpiritShieldedStatus extends RpgStatus

@export var ticks_between_decay: int

var _ticks_until_decay: int

func apply() -> void:
	_ticks_until_decay = ticks_between_decay
	effect.tick_callback = _tick
	super()

func _tick() -> void:
	_ticks_until_decay -= 1
	
	var spirit_shield = applied_to.get_capability(&"spirit_shield")
	assert(spirit_shield, "Character was given spirit shield but has no capability for it")
	
	if _ticks_until_decay <= 0:
		spirit_shield.current_value -= 1
		_ticks_until_decay = ticks_between_decay
	
	if spirit_shield.is_empty():
		remove()
