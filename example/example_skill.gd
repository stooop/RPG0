class_name ExampleSkill extends RpgSkill

enum TargetType {NONE, ONE_ENEMY, ONE_ALLY, SELF}

@export var target_type: TargetType
@export var cost: Dictionary # Keys are capability IDs, values are the cost amounts

func use(targets: Array[RpgCharacter]) -> void:
	# Have to check this here because it normally wouldn't be checked until after the capabilities are modified
	# That said, the UI should prevent this from ever happening
	if !can_use():
		return
	
	if cost.is_empty():
		super(targets)
		return
	
	for capability_id in cost.keys():
		user.get_capability(capability_id).current_value -= cost[capability_id]
	super(targets)

func can_use() -> bool:
	for capability_id in cost.keys():
		if user.get_capability(capability_id).current_value < cost[capability_id]:
			return false
	return super()

func get_interpolated_description() -> String:
	if cost.is_empty():
		return super()
	
	var cost_strings = []
	for capability_id in cost.keys():
		cost_strings.push_back("%d %s" % [cost[capability_id], user.get_capability(capability_id).name])
	
	return RpgUtils.interpolate_formatted_string("%s\nCost: %s" % [description, ", ".join(cost_strings)], self)
