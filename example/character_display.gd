extends Control

@export var character: ExampleCharacter

@onready var name_label: Label = $MainPanelContainer/HBoxContainer/NameLabel
@onready var hp_value_label: Label = $MainPanelContainer/HBoxContainer/ResourcesContainer/HpContainer/ValueLabel
@onready var ap_value_label: Label = $MainPanelContainer/HBoxContainer/ResourcesContainer/ApContainer/ValueLabel
@onready var button_containers: TabContainer = $ButtonContainers
@onready var skill_buttons_container: VBoxContainer = $ButtonContainers/Skills
@onready var skills_button: Button = $ButtonContainers/TopLevel/SkillsButton
@onready var cancel_targeting_button: Button = $ButtonContainers/Targeting/CancelTargetingButton
@onready var main_panel_container: PanelContainer = $MainPanelContainer

signal started_targeting_mode(skill: ExampleSkill)
signal canceled_targeting_mode
signal main_panel_clicked

func _ready() -> void:
	character.turn_started.connect(_on_turn_started)
	character.turn_ended.connect(_on_turn_ended)
	
	skills_button.pressed.connect(_on_skills_button_pressed)
	cancel_targeting_button.pressed.connect(_cancel_targeting_mode)
	
	main_panel_container.gui_input.connect(_on_main_panel_input)

func _physics_process(_delta: float) -> void:
	if !character:
		return
	
	name_label.text = character.name
	hp_value_label.text = "%d/%d" % [character.get_combat_resource(&"health").current_value, character.get_stat(&"max_health").get_modified_value()]
	ap_value_label.text = "%d/%d" % [character.action_points, character.get_action_point_threshold()]

func _on_turn_started() -> void:
	if character.team != RpgEnums.Team.PLAYER:
		return
	
	button_containers.visible = true
	button_containers.current_tab = 0

func _on_turn_ended() -> void:
	if character.team != RpgEnums.Team.PLAYER:
		return
	
	button_containers.visible = false

func _on_skills_button_pressed() -> void:
	button_containers.current_tab = 1
	
	for child in skill_buttons_container.get_children():
		child.queue_free()
	
	for skill in character.skills:
		var button = Button.new()
		button.text = skill.name
		button.tooltip_text = skill.get_interpolated_description()
		button.pressed.connect(func(): _start_targeting_mode(skill))
		skill_buttons_container.add_child(button)

func _start_targeting_mode(skill: ExampleSkill) -> void:
	button_containers.current_tab = 2
	started_targeting_mode.emit(skill)

func _cancel_targeting_mode() -> void:
	button_containers.current_tab = 1
	canceled_targeting_mode.emit()

func on_targeting_mode_stopped() -> void:
	button_containers.current_tab = 1

func _on_main_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		main_panel_clicked.emit()
