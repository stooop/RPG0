class_name RpgModifier extends Object

var type: RpgEnums.ModifierType
var value_callback: Callable

func get_value() -> float:
	return value_callback.call()
