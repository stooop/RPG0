class_name StunnedStatusEffect extends RpgStatusEffect

@export var duration: int

var _ticks: int = 0

func tick() -> void:
	_ticks += 1
	if _ticks >= duration:
		remove()

func modify_stacks(_s: int) -> void:
	_ticks = 0
