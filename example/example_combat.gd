extends Node2D

const character_display_scene: PackedScene = preload("res://example/character_display.tscn")

@onready var player_character_display_container: HBoxContainer = $CanvasLayer/PlayerCharacterDisplayContainer
@onready var opponent_character_display_container: HBoxContainer = $CanvasLayer/OpponentCharacterDisplayContainer

var _targeting_mode_skill: ExampleSkill

signal stopped_targeting_mode

func _ready() -> void:
	_register_static_data()
	
	# Set up characters. Normally I recommend you maintain a "party array" that you can pass directly into start_combat()
	var hero = RpgRegistry.get_character(&"hero")
	hero.team = RpgEnums.Team.PLAYER
	hero.order = 0
	hero.add_default_stats() \
		.add_default_capabilities() \
		.add_new_skill(&"slash", 1) \
		.add_new_skill(&"fortify", 1)
	
	var cowboy = RpgRegistry.get_character(&"cowboy")
	cowboy.team = RpgEnums.Team.PLAYER
	cowboy.order = 1
	cowboy.add_default_stats() \
		.add_default_capabilities() \
		.add_new_capability(&"ammo", 6) \
		.add_new_skill(&"shoot", 1) \
		.add_new_skill(&"reload", 1) \
		.add_new_skill(&"drink", 1) \
		.add_new_skill(&"lasso", 1)
	
	RpgGameState.add_new_combatant(&"goblin", RpgEnums.Team.OPPONENT, 0) \
		.add_default_stats() \
		.add_default_capabilities() \
		.add_new_skill(&"slash", 1)
	
	RpgGameState.add_new_combatant(&"goblin", RpgEnums.Team.OPPONENT, 1) \
		.add_default_stats() \
		.add_default_capabilities() \
		.add_new_skill(&"slash", 1)
	
	# Set up monster behavior (very basic, but gives you an idea of how it could work with more complex AI)
	for character in RpgGameState.get_combatants(RpgEnums.Team.OPPONENT):
		character.turn_started.connect(func(): _on_opponent_turn_started(character))
	
	RpgGameState.start_combat([hero, cowboy])
	
	_create_ui()

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
	var skill = character.skills.filter(func(x): return x.can_use()).pick_random()
	var targets: Array[RpgCharacter] = [RpgGameState.get_combatants(RpgEnums.Team.PLAYER).pick_random()]
	skill.use(targets)

func _register_static_data() -> void:
	# Normally this would be done in an autoload script and use resource files, JSON, etc
	var hero_data = ExampleCharacter.new()
	hero_data.id = &"hero"
	hero_data.name = "Hero"
	hero_data.base_stats = {"speed": 100, "max_health": 100, "max_mana": 100, "attack": 10}
	RpgRegistry.register_character(hero_data)
	
	var cowboy_data = ExampleCharacter.new()
	cowboy_data.id = &"cowboy"
	cowboy_data.name = "Cowboy"
	cowboy_data.base_stats = {"speed": 105, "max_health": 80, "max_mana": 50, "attack": 15}
	RpgRegistry.register_character(cowboy_data)
	
	var goblin_data = ExampleCharacter.new()
	goblin_data.id = &"goblin"
	goblin_data.name = "Goblin"
	goblin_data.base_stats = {"speed": 75, "max_health": 50, "max_mana": 25, "attack": 3}
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
	
	var max_mana_data = RpgStat.new()
	max_mana_data.id = &"max_mana"
	max_mana_data.name = "Wisdom"
	max_mana_data.min_value = 1
	max_mana_data.max_value = 9999
	RpgRegistry.register_stat(max_mana_data)
	
	var attack_data = RpgStat.new()
	attack_data.id = &"attack"
	attack_data.name = "Attack"
	attack_data.min_value = 0
	attack_data.max_value = 99
	RpgRegistry.register_stat(attack_data)
	
	var health_data = RpgCapability.new()
	health_data.id = &"health"
	health_data.name = "Health"
	health_data.absolute_min = 0
	health_data.absolute_max = 9999
	health_data.max_stat_binding = &"max_health"
	RpgRegistry.register_capability(health_data)
	
	var mana_data = RpgCapability.new()
	mana_data.id = &"mana"
	mana_data.name = "Mana"
	mana_data.absolute_min = 0
	mana_data.absolute_max = 9999
	mana_data.max_stat_binding = &"max_mana"
	RpgRegistry.register_capability(mana_data)
	
	var spirit_shield_data = RpgCapability.new()
	spirit_shield_data.id = &"spirit_shield"
	spirit_shield_data.name = "Spirit Shield"
	spirit_shield_data.absolute_min = 0
	spirit_shield_data.absolute_max = 9999
	RpgRegistry.register_capability(spirit_shield_data)
	
	var ammo_data = RpgCapability.new()
	ammo_data.id = &"ammo"
	ammo_data.name = "Ammo"
	ammo_data.absolute_min = 0
	ammo_data.absolute_max = 6
	RpgRegistry.register_capability(ammo_data)
	
	var slash_data = SlashSkill.new()
	slash_data.id = &"slash"
	slash_data.name = "Slash"
	slash_data.description = "Attack one enemy for {get_damage_floor()}-{get_damage_ceiling()} damage."
	slash_data.target_type = ExampleSkill.TargetType.ONE_ENEMY
	RpgRegistry.register_skill(slash_data)
	
	var fortify_data = FortifySkill.new()
	fortify_data.id = &"fortify"
	fortify_data.name = "Fortify"
	fortify_data.description = "Gain {get_shield_amount()} spirit shield."
	fortify_data.cost = {&"mana": 10}
	fortify_data.target_type = ExampleSkill.TargetType.SELF
	RpgRegistry.register_skill(fortify_data)
	
	var shoot_skill = ShootSkill.new()
	shoot_skill.id = &"shoot"
	shoot_skill.name = "Shoot"
	shoot_skill.description = "Attack one enemy for {get_damage_amount()} damage. If the target is slowed or stunned, deal an additional {get_bonus_damage_amount()} damage."
	shoot_skill.cost = {&"ammo": 1}
	shoot_skill.target_type = ExampleSkill.TargetType.ONE_ENEMY
	shoot_skill.bonus_damage_percent = 0.5
	RpgRegistry.register_skill(shoot_skill)
	
	var reload_skill = ReloadSkill.new()
	reload_skill.id = &"reload"
	reload_skill.name = "Reload"
	reload_skill.description = "Reload to full ammo."
	reload_skill.cost = {&"mana": 20}
	reload_skill.target_type = ExampleSkill.TargetType.SELF
	RpgRegistry.register_skill(reload_skill)
	
	var drink_skill = DrinkSkill.new()
	drink_skill.id = &"drink"
	drink_skill.name = "Drink"
	drink_skill.description = "Restore {get_restoration_amount()} mana and gain 1 stack of tipsy."
	drink_skill.target_type = ExampleSkill.TargetType.SELF
	RpgRegistry.register_skill(drink_skill)
	
	var lasso_skill = LassoSkill.new()
	lasso_skill.id = &"lasso"
	lasso_skill.name = "Lasso"
	lasso_skill.description = "Inflict 1 stack of slowed."
	lasso_skill.cost = {&"mana": 10}
	lasso_skill.target_type = ExampleSkill.TargetType.ONE_ENEMY
	RpgRegistry.register_skill(lasso_skill)
	
	var poisoned_data = PoisionedStatus.new()
	poisoned_data.id = &"poisoned"
	poisoned_data.name = "Poisoned"
	poisoned_data.description = "Each stack deals 1 damage every {ticks_between_damage} ticks {total_procs} times."
	poisoned_data.max_stacks = 99
	poisoned_data.ticks_between_damage = 50
	poisoned_data.total_procs = 5
	RpgRegistry.register_status(poisoned_data)
	
	var slowed_data = SlowedStatus.new()
	slowed_data.id = &"slowed"
	slowed_data.name = "Slowed"
	slowed_data.description = "Each stack reduces speed by {slow_amount * 100}% for 1 turn."
	slowed_data.max_stacks = 5
	slowed_data.slow_amount = 0.1
	RpgRegistry.register_status(slowed_data)
	
	var silenced_data = SilencedStatus.new()
	silenced_data.id = &"silenced"
	silenced_data.name = "Silenced"
	silenced_data.description = "Cannot take a turn for {duration} ticks."
	silenced_data.max_stacks = 1
	silenced_data.duration = 40
	RpgRegistry.register_status(silenced_data)
	
	var stunned_data = StunnedStatus.new()
	stunned_data.id = &"stunned"
	stunned_data.name = "Stunned"
	stunned_data.description = "Cannot gain AP for {duration} ticks."
	stunned_data.max_stacks = 1
	stunned_data.duration = 40
	RpgRegistry.register_status(stunned_data)
	
	var spirit_shielded_data = SpiritShieldedStatus.new()
	spirit_shielded_data.id = &"spirit_shielded"
	spirit_shielded_data.name = "Spirit Shielded"
	spirit_shielded_data.description = "Spirit shield absorbs damage and decays by 1 every {ticks_between_decay} ticks."
	spirit_shielded_data.max_stacks = 1
	spirit_shielded_data.ticks_between_decay = 60
	RpgRegistry.register_status(spirit_shielded_data)
	
	var tipsy_data = TipsyStatus.new()
	tipsy_data.id = &"tipsy"
	tipsy_data.name = "Tipsy"
	tipsy_data.description = "Each stack reduces attack by {damage_reduction_amount * 100}%."
	tipsy_data.max_stacks = 5
	tipsy_data.damage_reduction_amount = 0.15
	RpgRegistry.register_status(tipsy_data)
