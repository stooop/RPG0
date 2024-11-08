extends Node

var is_combat_active: bool = false
var combatants: Array[RpgCharacter] = []
var combat_tick: int = 0
var do_ticks: bool = true

signal combat_started
signal combat_finalized(winning_team: RpgEnums.Team)
signal turn_started(character: RpgCharacter)

func _physics_process(_delta: float) -> void:
	if !is_combat_active or !do_ticks:
		return
	
	# TODO: Check if any team has won
	
	# Check if any combatants are ready to take their turn
	_sort_characters_by_speed(combatants) # Will usually be sorted already, so negligible performance impact
	for character in combatants:
		if !character.can_take_turn():
			continue
		
		# Set up for character's turn, can be handled using signal or overridden RpgCharacter.start_turn()
		do_ticks = false
		turn_started.emit(character)
		character.start_turn()
		return
	
	# If no one is ready, tick all combatants
	combat_tick += 1
	for character in combatants:
		character.action_points += 1 # TODO: Add a way to prevent gaining AP for death and stuns

# Start combat with characters added previously and/or passed to this function
func start_combat(characters: Array[RpgCharacter] = []) -> void:
	assert(!is_combat_active)
	is_combat_active = true
	do_ticks = true
	combat_tick = 0
	
	add_combatants(characters)
	assert(!combatants.is_empty()) # You should always have combatants, if needed you can call add_new_combatant() before start_combat()
	
	_sort_characters_by_speed(combatants)
	
	combat_started.emit()

# Stop the active combat, make sure to call end_combat() after
func finalize_combat(winning_team: RpgEnums.Team) -> void:
	assert(is_combat_active)
	is_combat_active = false
	combat_finalized.emit(winning_team)

# Reset combat state for next combat
func end_combat() -> void:
	assert(!is_combat_active)
	combat_tick = 0
	for character in combatants:
		character.action_points = 0
	combatants.clear()

# Add a new character to the current/next combat based on a character ID
func add_new_combatant(character_id: StringName, team: RpgEnums.Team, order: int) -> RpgCharacter:
	var character = RpgRegistry.get_character(character_id)
	character.team = team
	character.order = order
	
	return add_combatant(character)

# Add an existing character to the current/next combat
func add_combatant(character: RpgCharacter) -> RpgCharacter:
	character.action_points = 0
	combatants.push_back(character)
	return character

# Add existing characters to the current/next combat
func add_combatants(characters: Array[RpgCharacter]) -> void:
	for character in characters:
		character.action_points = 0
	combatants.append_array(characters)

# Get all combatants on one team sorted by their order
func get_combatants(team: RpgEnums.Team) -> Array[RpgCharacter]:
	var to_return = combatants.filter(func(x): return x.team == team)
	to_return.sort_custom(func(a, b): return a.order < b.order)
	return to_return

func _sort_characters_by_speed(characters: Array) -> void:
	# Includes secondary sorting by team and order to guarantee stable/unique sorting
	characters.sort_custom(func(a, b): return a.get_speed() >= b.get_speed() and a.team <= b.team and a.order < b.order)
