class_name RpgCharacter extends Resource

# Static data
@export var id: StringName
@export var name: String
@export_multiline var description: String
@export var base_stats: Dictionary # Keys are RpgStat IDs, values will be used in add_new_stat()

var team: RpgEnums.Team
var experience: int
var order: int # Used for some sorting. Generally meant to represent party position from left to right.
var stats: Array[RpgStat] = []
var capabilities: Array[RpgCapability] = []
var skills: Array[RpgSkill] = []
var statuses: Array[RpgStatus] = []
var action_points: int

signal turn_ready
signal turn_started
signal turn_ended
signal ticked
signal used_skill(skill: RpgSkill, targets: Array[RpgCharacter]) # Fires after RpgSkill.used
signal hp_changed
signal died
signal statuses_changed

func tick() -> void:
	ticked.emit()
	if can_gain_action_points():
		action_points += 1
		if can_take_turn():
			turn_ready.emit()

# Can be overridden to handle a character's turn starting, e.g. with UI
func start_turn() -> void:
	turn_started.emit()

# Call this after a character's turn is over
func end_turn() -> void:
	action_points = 0
	turn_ended.emit()

# Override this if you use a different capability ID for HP
func is_dead() -> bool:
	return get_capability(&"health").is_empty()

# Can be overriden for a "silence" status effect
func can_take_turn() -> bool:
	return !is_dead() and action_points >= get_action_point_threshold()

# Can be overriden for a "stun" status effect
func can_gain_action_points() -> bool:
	return !is_dead()

func add_capability(capability: RpgCapability) -> RpgCharacter:
	capabilities.push_back(capability)
	return self

func add_new_capability(id: StringName, initial_value: float) -> RpgCharacter:
	var capability = RpgRegistry.get_capability(id)
	if !capability.max_stat_binding.is_empty():
		get_stat(capability.max_stat_binding).value_changed.connect(capability.set_bound_max)
		capability.set_bound_max(get_stat(capability.max_stat_binding).get_modified_value())
	if !capability.min_stat_binding.is_empty():
		get_stat(capability.min_stat_binding).value_changed.connect(capability.set_bound_min)
		capability.set_bound_min(get_stat(capability.min_stat_binding).get_modified_value())
	capability.current_value = initial_value
	return add_capability(capability)

func get_capability(id: StringName) -> RpgCapability:
	var matching = capabilities.filter(func(x): return x.id == id)
	if matching.is_empty():
		return null
	return matching.front()

func add_stat(stat: RpgStat) -> RpgCharacter:
	stats.push_back(stat)
	return self

func add_new_stat(id: StringName) -> RpgCharacter:
	var stat = RpgRegistry.get_stat(id)
	stat.base_value = base_stats[id]
	assert(stat.base_value <= stat.max_value and stat.base_value >= stat.min_value, "New stat's base value is not within bounds")
	return add_stat(stat)

func get_stat(id: StringName) -> RpgStat:
	var matching = stats.filter(func(x): return x.id == id)
	if matching.is_empty():
		return null
	return matching.front()

func add_skill(skill: RpgSkill) -> RpgCharacter:
	skill.user = self
	skills.push_back(skill)
	skill.used.connect(func(source, targets): used_skill.emit(skill, targets))
	return self

func add_new_skill(id: StringName, tier: int) -> RpgCharacter:
	var skill = RpgRegistry.get_skill(id)
	skill.tier = tier
	return add_skill(skill)

func get_skill(id: StringName) -> RpgSkill:
	var matching = skills.filter(func(x): return x.id == id)
	if matching.is_empty():
		return null
	return matching.front()

func get_skill_by_tier(id: StringName, tier: int) -> RpgSkill:
	var matching = skills.filter(func(x): return x.id == id and x.tier == tier)
	if matching.is_empty():
		return null
	return matching.front()

func add_status(status: RpgStatus) -> RpgCharacter:
	var existing = get_status(status.id)
	if !existing:
		statuses.push_back(status)
		if status.stacks == 0:
			status.stacks = 1
		status.applied_to = self
		status.apply()
		statuses_changed.emit()
	else:
		var old_stacks = existing.stacks
		existing.modify_stacks(status.stacks)
		if existing.stacks != old_stacks:
			statuses_changed.emit()
	return self

func add_new_status(id: StringName, stacks: int = 1) -> RpgCharacter:
	var status = RpgRegistry.get_status(id)
	status.stacks = stacks
	return add_status(status)

func get_status(id: StringName) -> RpgStatus:
	var matching = statuses.filter(func(x): return x.id == id)
	if matching.is_empty():
		return null
	return matching.front()

func remove_status(id: StringName) -> void:
	var matching = get_status(id)
	assert(matching, "Tried to remove a nonexistent status %s" % id)
	statuses.erase(matching)
	statuses_changed.emit()

# Heal or damage, override this if you use a different capability ID for HP or to add logic for resistances, etc.
# By default returns the damage done. In subclasses you can subtract out reduction from resistances, etc. or change the return type to be a more complex "damage report"
func modify_hp(amount: int, source: Variant = null) -> Variant:
	if is_dead() or amount == 0:
		return 0
	
	get_capability(&"health").current_value += amount
	hp_changed.emit()
	
	if is_dead():
		died.emit()
	
	return amount

# Fast way to get a character's speed for turn order purposes, can also be overriden if you don't want to use a speed stat
func get_speed() -> float:
	return get_stat(&"speed").get_modified_value()

func get_action_point_threshold() -> int:
	return (60 * RpgConstants.base_speed) / get_speed()

func get_interpolated_description() -> String:
	return RpgUtils.interpolate_formatted_string(description, self)
