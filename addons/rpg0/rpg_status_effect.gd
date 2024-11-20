class_name RpgStatusEffect extends Resource

# Static data
@export var id: StringName
@export var name: String
@export_multiline var description: String
@export var is_negative: bool
@export var max_stacks: int = 1

var stacks: int
var applied_to: RpgCharacter # Assigned in RpgCharacter.add_status_effect()

func apply() -> void:
	pass

func modify_stacks(s: int) -> void:
	stacks = clampi(stacks + s, 0, max_stacks)

func remove() -> void:
	applied_to.remove_status_effect(id)

func on_turn_start() -> void:
	pass

func tick() -> void:
	pass

func get_interpolated_description() -> String:
	return RpgUtils.interpolate_formatted_string(description, self)
