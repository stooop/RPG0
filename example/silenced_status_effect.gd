class_name SilencedStatusEffect extends RpgStatusEffect

@export var duration: int

var _ticks: int = 0

func tick() -> void:
	_ticks += 1
	if _ticks >= duration:
		remove()

func modify_stacks(s: int) -> void:
	super(s)
	_ticks = 0
