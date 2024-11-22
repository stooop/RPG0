class_name RpgCharacter extends Resource

# Static data
@export var id: StringName
@export var name: String
@export var base_stats: Dictionary # Keys are RpgStat IDs, values will be used in add_new_stat()

var team: RpgEnums.Team
var experience: int
var order: int # Used for some sorting. Generally meant to represent party position from left to right.
var stats: Array[RpgStat] = []
var combat_resources: Array[RpgCombatResource] = []
var skills: Array[RpgSkill] = []
var status_effects: Array[RpgStatusEffect] = []
var action_points: int

signal turn_ready
signal turn_started
signal turn_ended
signal used_skill(skill: RpgSkill, targets: Array[RpgCharacter]) # Fires after RpgSkill.used
signal died

func tick() -> void:
	for effect in status_effects:
		effect.tick()
	if can_gain_action_points():
		action_points += 1
		if can_take_turn():
			turn_ready.emit()

# Can be overridden to handle a character's turn starting, e.g. with UI
func start_turn() -> void:
	for effect in status_effects:
		effect.on_turn_start()
	turn_started.emit()

# Call this after a character's turn is over
func end_turn() -> void:
	action_points = 0
	turn_ended.emit()

# Override this if you use a different combat resource ID for HP
func is_dead() -> bool:
	return get_combat_resource(&"health").is_empty()

# Can be overriden for a "silence" status effect
func can_take_turn() -> bool:
	return !is_dead() and action_points >= get_action_point_threshold()

# Can be overriden for a "stun" status effect
func can_gain_action_points() -> bool:
	return !is_dead()

func add_combat_resource(resource: RpgCombatResource) -> RpgCharacter:
	combat_resources.push_back(resource)
	return self

func add_new_combat_resource(id: StringName, initial_value: float) -> RpgCharacter:
	var resource = RpgRegistry.get_combat_resource(id)
	if !resource.max_stat_binding.is_empty():
		get_stat(resource.max_stat_binding).value_changed.connect(resource._on_bound_max_changed)
	if !resource.min_stat_binding.is_empty():
		get_stat(resource.min_stat_binding).value_changed.connect(resource._on_bound_min_changed)
	resource.current_value = initial_value
	return add_combat_resource(resource)

func get_combat_resource(id: StringName) -> RpgCombatResource:
	var matching = combat_resources.filter(func(x): return x.id == id)
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

func add_status_effect(status_effect: RpgStatusEffect) -> RpgCharacter:
	var existing = get_status_effect(status_effect.id)
	if !existing:
		status_effects.push_back(status_effect)
		if status_effect.stacks == 0:
			status_effect.stacks = 1
		status_effect.applied_to = self
		status_effect.apply()
	else:
		existing.modify_stacks(status_effect.stacks)
	return self

func add_new_status_effect(id: StringName, stacks: int) -> RpgCharacter:
	var status_effect = RpgRegistry.get_status_effect(id)
	status_effect.stacks = stacks
	return add_status_effect(status_effect)

func get_status_effect(id: StringName) -> RpgStatusEffect:
	var matching = status_effects.filter(func(x): return x.id == id)
	if matching.is_empty():
		return null
	return matching.front()

func remove_status_effect(id: StringName) -> void:
	var matching = get_status_effect(id)
	assert(matching, "Tried to remove a nonexistent status effect %s" % id)
	status_effects.erase(matching)

# Heal or damage, override this if you use a different combat resource ID for HP or to add logic for resistances, etc.
func modify_hp(amount: int, source: Variant = null) -> void:
	if is_dead():
		return
	
	get_combat_resource(&"health").current_value += amount
	
	if is_dead():
		died.emit()

# Fast way to get a character's speed for turn order purposes, can also be overriden if you don't want to use a speed stat
func get_speed() -> float:
	return get_stat(&"speed").get_modified_value()

func get_action_point_threshold() -> int:
	return (60 * RpgConstants.base_speed) / get_speed()
