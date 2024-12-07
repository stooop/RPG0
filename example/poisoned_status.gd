class_name PoisionedStatus extends RpgStatus

@export var ticks_between_damage: int
@export var total_procs: int

var _ticks_until_damage: int
var _procs_remaining: int

func apply() -> void:
	_ticks_until_damage = ticks_between_damage
	_procs_remaining = total_procs
	
	effect.tick_callback = _tick
	
	super()

func modify_stacks(s: int) -> void:
	super(s)
	_ticks_until_damage = ticks_between_damage
	_procs_remaining = total_procs

func _tick() -> void:
	_ticks_until_damage -= 1
	if _ticks_until_damage <= 0:
		applied_to.modify_hp(-stacks, self)
		_procs_remaining -= 1
		_ticks_until_damage = ticks_between_damage
	
	if _procs_remaining <= 0:
		remove()
