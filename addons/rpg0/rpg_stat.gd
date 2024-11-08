class_name RpgStat extends Resource

# Static data
@export var id: StringName
@export var name: String
@export var min_value: float
@export var max_value: float

var base_value: float # Generally should not be changed after initially set, use modifiers for that

signal value_changed(new_value: float) # TODO: Emit this based on modifiers
