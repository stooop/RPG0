class_name StunnedStatus extends RpgStatus

@export var duration: int

var _ticks: int = 0

func apply() -> void:
	effect.tick_callback = _tick
	super()

func _tick() -> void:
	_ticks += 1
	if _ticks >= duration:
		remove()

func modify_stacks(_s: int) -> void:
	_ticks = 0
