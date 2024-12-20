class_name RpgCapability extends Resource

# Static data
@export var id: StringName
@export var name: String
@export var absolute_min: float:
	set(value):
		_current_min = value
		absolute_min = value
@export var absolute_max: float:
	set(value):
		_current_max = value
		absolute_max = value
@export var min_stat_binding: StringName
@export var max_stat_binding: StringName

var current_value: float:
	set(value):
		current_value = clampf(value, _current_min, _current_max)

var _current_max: float
var _current_min: float

# Connected in RpgCharacter.add_new_capability()
func set_bound_max(new_value: float) -> void:
	assert(new_value <= absolute_max, "Absolute max should be higher than the bound stat")
	_current_max = new_value
	current_value = current_value # Looks silly but need to re-clamp

# Connected in RpgCharacter.add_new_capability()
func set_bound_min(new_value: float) -> void:
	assert(new_value >= absolute_min, "Absolute min should be lower than the bound stat")
	_current_min = new_value
	current_value = current_value # Looks silly but need to re-clamp

# Override this for capabilites that work differently, e.g. generative resources like energy or armor
func reset() -> RpgCapability:
	current_value = _current_max
	return self

func is_empty() -> bool:
	return is_equal_approx(current_value, _current_min)

func is_full() -> bool:
	return is_equal_approx(current_value, _current_max)
