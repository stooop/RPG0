extends Control

@export var character: ExampleCharacter

@onready var name_label: Label = $MainPanelContainer/HBoxContainer/NameLabel
@onready var hp_value_label: Label = $MainPanelContainer/HBoxContainer/CapabilitiesContainer/HpContainer/ValueLabel
@onready var mp_value_label: Label = $MainPanelContainer/HBoxContainer/CapabilitiesContainer/MpContainer/ValueLabel
@onready var ap_value_label: Label = $MainPanelContainer/HBoxContainer/CapabilitiesContainer/ApContainer/ValueLabel
@onready var button_containers: TabContainer = $ButtonContainers
@onready var skill_buttons_container: VBoxContainer = $ButtonContainers/Skills
@onready var skills_button: Button = $ButtonContainers/TopLevel/SkillsButton
@onready var cancel_targeting_button: Button = $ButtonContainers/Targeting/CancelTargetingButton
@onready var main_panel_container: PanelContainer = $MainPanelContainer
@onready var status_container: HFlowContainer = $StatusContainer

signal started_targeting_mode(skill: ExampleSkill)
signal canceled_targeting_mode
signal main_panel_clicked

func _ready() -> void:
	character.turn_started.connect(_on_turn_started)
	character.turn_ended.connect(_on_turn_ended)
	character.statuses_changed.connect(_on_statuses_changed)
	
	skills_button.pressed.connect(_on_skills_button_pressed)
	cancel_targeting_button.pressed.connect(_cancel_targeting_mode)
	
	main_panel_container.gui_input.connect(_on_main_panel_input)

func _physics_process(_delta: float) -> void:
	if !character:
		return
	
	# Main panel labels
	name_label.text = character.name
	hp_value_label.text = "%d/%d" % [character.get_capability(&"health").current_value, character.get_stat(&"max_health").get_modified_value()]
	mp_value_label.text = "%d/%d" % [character.get_capability(&"mana").current_value, character.get_stat(&"max_mana").get_modified_value()]
	ap_value_label.text = "%d/%d" % [character.action_points, character.get_action_point_threshold()]
	
	var spirit_shield = character.get_capability(&"spirit_shield")
	if spirit_shield and spirit_shield.current_value > 0:
		hp_value_label.text += " (+%d)" % spirit_shield.current_value

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
		button.pressed.connect(func(): _start_skill(skill))
		skill_buttons_container.add_child(button)
		if !skill.can_use():
			button.disabled = true

func _start_skill(skill: ExampleSkill) -> void:
	if skill.target_type == ExampleSkill.TargetType.SELF:
		skill.use([skill.user])
	else:
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

func _on_statuses_changed() -> void:
	for child in status_container.get_children():
		child.queue_free()
	
	for status in character.statuses:
		var label = Label.new()
		label.text = "%s (%d)" % [status.name, status.stacks]
		label.tooltip_text = status.get_interpolated_description()
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		status_container.add_child(label)
