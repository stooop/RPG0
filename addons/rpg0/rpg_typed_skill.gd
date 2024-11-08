class_name RpgTypedSkill extends RpgSkill

func _init(skill_id: StringName, skill_tier: int) -> void:
	# This could be future-proofed by using reflection, e.g. base.get_script().get_script_property_list()
	var base = RpgRegistry.get_skill(skill_id)
	id = base.id
	name = base.name
	description = base.description
	can_use_outside_combat = base.can_use_outside_combat
	tier = skill_tier
