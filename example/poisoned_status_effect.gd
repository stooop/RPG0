class_name PoisionedStatusEffect extends RpgTypedStatusEffect

const TICKS_BETWEEN_DAMAGE: int = 50
const TOTAL_PROCS: int = 5

var _ticks_until_damage: int = TICKS_BETWEEN_DAMAGE
var _procs_remaining: int = TOTAL_PROCS

func _init(initial_stacks: int) -> void:
	super(&"poisoned", initial_stacks)

func modify_stacks(s: int) -> void:
	super(s)
	_ticks_until_damage = TICKS_BETWEEN_DAMAGE
	_procs_remaining = TOTAL_PROCS

func tick() -> void:
	_ticks_until_damage -= 1
	if _ticks_until_damage <= 0:
		applied_to.modify_hp(-stacks)
		_procs_remaining -= 1
		_ticks_until_damage = TICKS_BETWEEN_DAMAGE
	
	if _procs_remaining <= 0:
		remove()
