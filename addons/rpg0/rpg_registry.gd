extends Node

var _characters: Dictionary
var _stats: Dictionary
var _capabilities: Dictionary
var _skills: Dictionary
var _statuses: Dictionary

func register_character(data: RpgCharacter) -> void:
	assert(!_characters.has(data.id), "Another character with ID %s is already registered" % data.id)
	_characters[data.id] = data

func get_character(id: StringName) -> RpgCharacter:
	assert(_characters.has(id), "Character ID %s not found" % id)
	return _duplicate_data(_characters[id])

func register_stat(data: RpgStat) -> void:
	assert(!_stats.has(data.id), "Another stat with ID %s is already registered" % data.id)
	_stats[data.id] = data

func get_stat(id: StringName) -> RpgStat:
	assert(_stats.has(id), "Stat ID %s not found" % id)
	return _duplicate_data(_stats[id])

func register_capability(data: RpgCapability) -> void:
	assert(!_capabilities.has(data.id), "Another combat resource with ID %s is already registered" % data.id)
	_capabilities[data.id] = data

func get_capability(id: StringName) -> RpgCapability:
	assert(_capabilities.has(id), "Combat resource ID %s not found" % id)
	return _duplicate_data(_capabilities[id])

func register_skill(data: RpgSkill) -> void:
	assert(!_skills.has(data.id), "Another skill with ID %s is already registered" % data.id)
	_skills[data.id] = data

func get_skill(id: StringName) -> RpgSkill:
	assert(_skills.has(id), "Skill ID %s not found" % id)
	return _duplicate_data(_skills[id])

func register_status(data: RpgStatus) -> void:
	assert(!_statuses.has(data.id), "Another status effect with ID %s is already registered" % data.id)
	_statuses[data.id] = data

func get_status(id: StringName) -> RpgStatus:
	assert(_statuses.has(id), "Status effect ID %s not found" % id)
	return _duplicate_data(_statuses[id])

# There's some issue with Resource.duplicate() missing properties in derived classes, so I'm just rolling my own deep copy method for now
func _duplicate_data(data_object: Object) -> Variant:
	var props = data_object.get_script().get_script_property_list()
	var dupe = load(data_object.get_script().resource_path).new()
	for prop in props:
		if prop.name in dupe:
			var value = data_object.get(prop.name)
			if typeof(value) == Variant.Type.TYPE_OBJECT: # Not worried about objects for now, could recursively call this function to copy
				continue
			elif typeof(value) >= Variant.Type.TYPE_ARRAY: # All array types are passed by reference, so we need to deep copy them
				dupe.set(prop.name, value.duplicate(true))
			elif typeof(value) == Variant.Type.TYPE_DICTIONARY: # Dictionaries are passed by reference, so we need to deep copy them
				dupe.set(prop.name, value.duplicate(true))
			else:
				dupe.set(prop.name, value)
	return dupe
