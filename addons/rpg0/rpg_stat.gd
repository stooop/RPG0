class_name RpgStat extends Resource

# Static data
@export var id: StringName
@export var name: String
@export var min_value: float
@export var max_value: float

var base_value: float # Generally should not be changed after initially set, use modifiers for that
var modifiers: Array[RpgModifier] = []

signal value_changed(new_value: float)

func add_modifier(modifier: RpgModifier) -> RpgStat:
	var previous_value = get_modified_value()
	modifiers.push_back(modifier)
	modifiers.sort_custom(func(a, b): return a.type < b.type) # Modifiers will be applied in the order listed in RpgEnums
	var new_value = get_modified_value()
	if !is_equal_approx(new_value, previous_value):
		value_changed.emit(new_value)
	return self

func remove_modifier(modifier: RpgModifier) -> void:
	var previous_value = get_modified_value()
	modifiers.erase(modifier)
	modifiers.sort_custom(func(a, b): return a.type < b.type)
	var new_value = get_modified_value()
	if !is_equal_approx(new_value, previous_value):
		value_changed.emit(new_value)

func get_modified_value() -> float:
	var mod_value = base_value
	for modifier in modifiers:
		match modifier.type:
			RpgEnums.ModifierType.ADDITIVE:
				mod_value += modifier.get_value()
			RpgEnums.ModifierType.MULTIPLICATIVE:
				mod_value *= modifier.get_value()
			_:
				assert(false, "Unknown modifier type on stat") # To implement other modifier types, you will need to override this method
		
		if mod_value >= max_value:
			return max_value
		elif mod_value <= min_value:
			return min_value
	return mod_value
