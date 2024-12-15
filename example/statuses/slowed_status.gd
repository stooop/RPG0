class_name SlowedStatus extends RpgStatus

@export var slow_amount: float

var _modifier: RpgModifier

func apply() -> void:
	_modifier = RpgModifier.new()
	_modifier.type = RpgEnums.ModifierType.MULTIPLICATIVE
	_modifier.value_callback = func(): return 1 - (slow_amount * stacks)
	applied_to.get_stat(&"speed").add_modifier(_modifier)
	
	effect.turn_start_callback = remove
	super()

func remove() -> void:
	super()
	applied_to.get_stat(&"speed").remove_modifier(_modifier)
