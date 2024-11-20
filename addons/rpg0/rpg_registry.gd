extends Node

var _characters: Dictionary
var _stats: Dictionary
var _combat_resources: Dictionary
var _skills: Dictionary
var _status_effects: Dictionary

func register_character(data: RpgCharacter) -> void:
	assert(!_characters.has(data.id), "Another character with ID %s is already registered" % data.id)
	_characters[data.id] = data

func get_character(id: StringName) -> RpgCharacter:
	assert(_characters.has(id), "Character ID %s not found" % id)
	return _characters[id].duplicate()

func register_stat(data: RpgStat) -> void:
	assert(!_stats.has(data.id), "Another stat with ID %s is already registered" % data.id)
	_stats[data.id] = data

func get_stat(id: StringName) -> RpgStat:
	assert(_stats.has(id), "Stat ID %s not found" % id)
	return _stats[id].duplicate()

func register_combat_resource(data: RpgCombatResource) -> void:
	assert(!_combat_resources.has(data.id), "Another combat resource with ID %s is already registered" % data.id)
	_combat_resources[data.id] = data

func get_combat_resource(id: StringName) -> RpgCombatResource:
	assert(_combat_resources.has(id), "Combat resource ID %s not found" % id)
	return _combat_resources[id].duplicate()

func register_skill(data: RpgSkill) -> void:
	assert(!_skills.has(data.id), "Another skill with ID %s is already registered" % data.id)
	_skills[data.id] = data

func get_skill(id: StringName) -> RpgSkill:
	assert(_skills.has(id), "Skill ID %s not found" % id)
	return _skills[id].duplicate()

func register_status_effect(data: RpgStatusEffect) -> void:
	assert(!_status_effects.has(data.id), "Another status effect with ID %s is already registered" % data.id)
	_status_effects[data.id] = data

func get_status_effect(id: StringName) -> RpgStatusEffect:
	assert(_status_effects.has(id), "Status effect ID %s not found" % id)
	return _status_effects[id].duplicate()
