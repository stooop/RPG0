class_name RpgStatus extends Resource

# Static data
@export var id: StringName
@export var name: String
@export_multiline var description: String
@export var max_stacks: int = 1

var effect: RpgTriggeredEffect = RpgTriggeredEffect.new()
var stacks: int
var applied_to: RpgCharacter # Assigned in RpgCharacter.add_status()

func apply() -> void:
	effect.connect_all(applied_to)

func modify_stacks(s: int) -> void:
	stacks = clampi(stacks + s, 0, max_stacks)

func remove() -> void:
	effect.disconnect_all()
	applied_to.remove_status(id)

func get_interpolated_description() -> String:
	return RpgUtils.interpolate_formatted_string(description, self)
