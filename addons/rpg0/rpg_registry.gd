extends Node

var _characters: Dictionary
var _stats: Dictionary
var _combat_resources: Dictionary
var _skills: Dictionary

func register_character(data: RpgCharacter) -> void:
	assert(!_characters.has(data.id))
	_characters[data.id] = data

func get_character(id: StringName) -> RpgCharacter:
	assert(_characters.has(id))
	return _characters[id].duplicate()

func register_stat(data: RpgStat) -> void:
	assert(!_stats.has(data.id))
	_stats[data.id] = data

func get_stat(id: StringName) -> RpgStat:
	assert(_stats.has(id))
	return _stats[id].duplicate()

func register_combat_resource(data: RpgCombatResource) -> void:
	assert(!_combat_resources.has(data.id))
	_combat_resources[data.id] = data

func get_combat_resource(id: StringName) -> RpgCombatResource:
	assert(_combat_resources.has(id))
	return _combat_resources[id].duplicate()

func register_skill(data: RpgSkill) -> void:
	assert(!_skills.has(data.id))
	_skills[data.id] = data

func get_skill(id: StringName) -> RpgSkill:
	assert(_skills.has(id))
	return _skills[id].duplicate()
