class_name TipsyStatus extends RpgStatus

@export var damage_reduction_amount: float

var _modifier: RpgModifier

func apply() -> void:
	_modifier = RpgModifier.new()
	_modifier.type = RpgEnums.ModifierType.MULTIPLICATIVE
	_modifier.value_callback = func(): return 1 - (damage_reduction_amount * stacks)
	applied_to.get_stat(&"attack").add_modifier(_modifier)

	super()

func remove() -> void:
	super()
	applied_to.get_stat(&"attack").remove_modifier(_modifier)
