class_name SlowedStatusEffect extends RpgStatusEffect

@export var slow_amount: float

var _modifier: RpgModifier

func apply() -> void:
	_modifier = RpgModifier.new()
	_modifier.type = RpgEnums.ModifierType.MULTIPLICATIVE
	_modifier.value_callback = func(): return 1 - (slow_amount * stacks)
	applied_to.get_stat(&"speed").add_modifier(_modifier)

func remove() -> void:
	super()
	applied_to.get_stat(&"speed").remove_modifier(_modifier)

func on_turn_start() -> void:
	remove()
