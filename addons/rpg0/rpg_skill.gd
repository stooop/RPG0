class_name RpgSkill extends Resource

# Static data
@export var id: StringName
@export var name: String
@export_multiline var description: String
@export var can_use_outside_combat: bool

var tier: int
var user: RpgCharacter # Assigned in RpgCharacter.add_skill()

signal used(source: RpgCharacter, targets: Array[RpgCharacter])

# Override this to implement skill behavior
func use(targets: Array[RpgCharacter]) -> void:
	if !RpgGameState.is_combat_active and !can_use_outside_combat:
		return
	
	used.emit(user, targets)

func get_interpolated_description() -> String:
	return RpgUtils.interpolate_formatted_string(description, self)
