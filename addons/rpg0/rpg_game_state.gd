extends Node

var is_combat_active: bool = false
var combatants: Array[RpgCharacter] = []
var combat_tick: int = 0
var do_ticks: bool = true

var _ready_combatants: Array[RpgCharacter] = []

signal combat_started
signal combat_finalized(winning_team: RpgEnums.Team)

func _physics_process(_delta: float) -> void:
	if !is_combat_active or !do_ticks:
		return
	
	if _ready_combatants.is_empty():
		# Tick all combatants
		combat_tick += 1
		for character in combatants:
			character.tick()
	else:
		# Set up for character's turn, can be handled using signal or overridden RpgCharacter.start_turn()
		do_ticks = false
		_sort_characters_by_speed(_ready_combatants)
		var character = _ready_combatants.pop_front()
		character.start_turn()

# Start combat with characters added previously and/or passed to this function
func start_combat(characters: Array[RpgCharacter] = []) -> void:
	assert(!is_combat_active, "Combat is already active")
	is_combat_active = true
	do_ticks = true
	combat_tick = 0
	
	add_combatants(characters)
	assert(!combatants.is_empty(), "Cannot start combat without combatants") # if needed you can call add_new_combatant() before start_combat()
	
	combat_started.emit()

# Stop the active combat, make sure to call end_combat() after
func finalize_combat(winning_team: RpgEnums.Team) -> void:
	assert(is_combat_active, "No combat is active to finalize")
	is_combat_active = false
	combat_finalized.emit(winning_team)

# Reset combat state for next combat
func end_combat() -> void:
	assert(!is_combat_active, "Combat must be finalized before ending")
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
	character.turn_ready.connect(func(): _ready_combatants.push_back(character))
	character.turn_ended.connect(func(): do_ticks = true)
	character.died.connect(_check_for_winner)
	combatants.push_back(character)
	return character

# Add existing characters to the current/next combat
func add_combatants(characters: Array[RpgCharacter]) -> void:
	for character in characters:
		character.action_points = 0
		character.turn_ready.connect(func(): _ready_combatants.push_back(character))
		character.turn_ended.connect(func(): do_ticks = true)
		character.died.connect(_check_for_winner)
	combatants.append_array(characters)

# Get all combatants on one team sorted by their order
func get_combatants(team: RpgEnums.Team) -> Array[RpgCharacter]:
	var to_return = combatants.filter(func(x): return x.team == team)
	to_return.sort_custom(func(a, b): return a.order < b.order)
	return to_return

func _sort_characters_by_speed(characters: Array) -> void:
	# Includes secondary sorting by team and order to guarantee stable/unique sorting
	characters.sort_custom(func(a, b): return a.get_speed() >= b.get_speed() and a.team <= b.team and a.order < b.order)

func _check_for_winner() -> void:
	var living_teams = RpgEnums.Team.values()
	for team in RpgEnums.Team.values():
		var characters = combatants.filter(func(x): return x.team == team)
		if characters.is_empty():
			living_teams.erase(team) # Remove unused teams
		elif characters.all(func(x): return x.is_dead()):
			living_teams.erase(team) # Remove wiped teams
	assert(!living_teams.is_empty(), "All combatants are dead.") # TODO: Special logic for ties?
	if living_teams.size() == 1:
		finalize_combat(living_teams.front())
