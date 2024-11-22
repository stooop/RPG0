extends Node2D

const character_display_scene: PackedScene = preload("res://example/character_display.tscn")

@onready var player_character_display_container: HBoxContainer = $CanvasLayer/PlayerCharacterDisplayContainer
@onready var opponent_character_display_container: HBoxContainer = $CanvasLayer/OpponentCharacterDisplayContainer

var _targeting_mode_skill: ExampleSkill

signal stopped_targeting_mode

func _ready() -> void:
	_register_static_data()
	
	# Set up characters. Normally I recommend you maintain a "party array" that you can pass directly into start_combat()
	RpgGameState.add_new_combatant(&"hero", RpgEnums.Team.PLAYER, 0) \
		.add_default_stats() \
		.add_default_combat_resources() \
		.add_new_skill(&"slash", 1)
	
	RpgGameState.add_new_combatant(&"goblin", RpgEnums.Team.OPPONENT, 0) \
		.add_default_stats() \
		.add_default_combat_resources() \
		.add_new_skill(&"slash", 1)
	
	_create_ui()
	
	# Set up monster behavior (very basic, but gives you an idea of how it could work with more complex AI)
	for character in RpgGameState.get_combatants(RpgEnums.Team.OPPONENT):
		character.turn_started.connect(func(): _on_opponent_turn_started(character))
	
	RpgGameState.start_combat()

func _create_ui() -> void:
	for character in RpgGameState.get_combatants(RpgEnums.Team.PLAYER):
		var display = character_display_scene.instantiate()
		display.character = character
		display.main_panel_clicked.connect(func(): _on_character_display_clicked(character))
		display.started_targeting_mode.connect(_start_targeting_mode)
		display.canceled_targeting_mode.connect(_stop_targeting_mode)
		stopped_targeting_mode.connect(display.on_targeting_mode_stopped)
		player_character_display_container.add_child(display)
	
	for character in RpgGameState.get_combatants(RpgEnums.Team.OPPONENT):
		var display = character_display_scene.instantiate()
		display.character = character
		display.main_panel_clicked.connect(func(): _on_character_display_clicked(character))
		opponent_character_display_container.add_child(display)

func _start_targeting_mode(skill: ExampleSkill) -> void:
	_targeting_mode_skill = skill

func _stop_targeting_mode() -> void:
	_targeting_mode_skill = null
	stopped_targeting_mode.emit()

func _on_character_display_clicked(character: ExampleCharacter) -> void:
	if _targeting_mode_skill == null:
		return
	
	match _targeting_mode_skill.target_type:
		ExampleSkill.TargetType.ONE_ENEMY:
			if character.team != _targeting_mode_skill.user.team:
				_targeting_mode_skill.use([character])
				_stop_targeting_mode()
		ExampleSkill.TargetType.ONE_ALLY:
			if character.team == _targeting_mode_skill.user.team:
				_targeting_mode_skill.use([character])
				_stop_targeting_mode()
		_:
			assert(false)

func _on_opponent_turn_started(character: ExampleCharacter) -> void:
	var skill = character.skills.pick_random()
	var targets: Array[RpgCharacter] = [RpgGameState.get_combatants(RpgEnums.Team.PLAYER).pick_random()]
	skill.use(targets)

func _register_static_data() -> void:
	# Normally this would be done in an autoload script and use resource files, JSON, etc
	var hero_data = ExampleCharacter.new()
	hero_data.id = &"hero"
	hero_data.name = "Hero"
	hero_data.base_stats = {"speed": 100, "max_health": 100, "attack": 10}
	RpgRegistry.register_character(hero_data)
	
	var goblin_data = ExampleCharacter.new()
	goblin_data.id = &"goblin"
	goblin_data.name = "Goblin"
	goblin_data.base_stats = {"speed": 75, "max_health": 50, "attack": 3}
	RpgRegistry.register_character(goblin_data)
	
	var speed_data = RpgStat.new()
	speed_data.id = &"speed"
	speed_data.name = "Speed"
	speed_data.min_value = 1
	speed_data.max_value = 200
	RpgRegistry.register_stat(speed_data)
	
	var max_health_data = RpgStat.new()
	max_health_data.id = &"max_health"
	max_health_data.name = "Vitality"
	max_health_data.min_value = 1
	max_health_data.max_value = 9999
	RpgRegistry.register_stat(max_health_data)
	
	var attack_data = RpgStat.new()
	attack_data.id = &"attack"
	attack_data.name = "Attack"
	attack_data.min_value = 0
	attack_data.max_value = 99
	RpgRegistry.register_stat(attack_data)
	
	var health_data = RpgCombatResource.new()
	health_data.id = &"health"
	health_data.name = "Health"
	health_data.absolute_min = 0
	health_data.absolute_max = 9999
	health_data.max_stat_binding = &"max_health"
	RpgRegistry.register_combat_resource(health_data)
	
	var slash_data = SlashSkill.new()
	slash_data.id = &"slash"
	slash_data.name = "Slash"
	slash_data.description = "Attack one enemy for {get_damage_floor()}-{get_damage_ceiling()} damage."
	slash_data.target_type = ExampleSkill.TargetType.ONE_ENEMY
	RpgRegistry.register_skill(slash_data)
	
	var poisoned_data = PoisionedStatusEffect.new()
	poisoned_data.id = &"poisoned"
	poisoned_data.name = "Poisoned"
	poisoned_data.description = "Each stack deals 1 damage every {ticks_between_damage} ticks {total_procs} times."
	poisoned_data.max_stacks = 99
	poisoned_data.ticks_between_damage = 50
	poisoned_data.total_procs = 5
	RpgRegistry.register_status_effect(poisoned_data)
	
	var slowed_data = SlowedStatusEffect.new()
	slowed_data.id = &"slowed"
	slowed_data.name = "Slowed"
	slowed_data.description = "Each stack reduces speed by {slow_amount * 100}% for 1 turn."
	slowed_data.max_stacks = 5
	slowed_data.slow_amount = 0.1
	RpgRegistry.register_status_effect(slowed_data)
	
	var silenced_data = SilencedStatusEffect.new()
	silenced_data.id = &"silenced"
	silenced_data.name = "Silenced"
	silenced_data.description = "Cannot take a turn for {duration} ticks."
	silenced_data.max_stacks = 1
	silenced_data.duration = 40
	RpgRegistry.register_status_effect(silenced_data)
	
	var stunned_data = StunnedStatusEffect.new()
	stunned_data.id = &"stunned"
	stunned_data.name = "Stunned"
	stunned_data.description = "Cannot gain AP for {duration} ticks."
	stunned_data.max_stacks = 1
	stunned_data.duration = 40
	RpgRegistry.register_status_effect(stunned_data)
