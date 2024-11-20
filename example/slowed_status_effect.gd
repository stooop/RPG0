class_name SlowedStatusEffect extends RpgTypedStatusEffect

const SLOW_AMOUNT: float = 0.1

var _modifier: RpgModifier

func _init(initial_stacks: int) -> void:
	super(&"slowed", initial_stacks)
	_modifier = RpgModifier.new()
	_modifier.type = RpgEnums.ModifierType.MULTIPLICATIVE
	_modifier.value_callback = func(): return 1 - (SLOW_AMOUNT * stacks)

func apply() -> void:
	applied_to.get_stat(&"speed").add_modifier(_modifier)

func remove() -> void:
	super()
	applied_to.get_stat(&"speed").remove_modifier(_modifier)

func on_turn_start() -> void:
	remove()
