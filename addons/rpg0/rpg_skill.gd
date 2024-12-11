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
	if !can_use():
		return
	
	used.emit(user, targets)

# Override to add requirements/costs to skill use
func can_use() -> bool:
	return RpgGameState.is_combat_active or can_use_outside_combat

func get_interpolated_description() -> String:
	return RpgUtils.interpolate_formatted_string(description, self)
