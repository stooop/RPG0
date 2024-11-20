class_name RpgTypedStatusEffect extends RpgStatusEffect

func _init(effect_id: StringName, initial_stacks: int) -> void:
	var base = RpgRegistry.get_status_effect(effect_id)
	id = base.id
	name = base.name
	description = base.description
	is_negative = base.is_negative
	max_stacks = base.max_stacks
	stacks = clampi(initial_stacks, 0, max_stacks)
