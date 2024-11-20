class_name SilencedStatusEffect extends RpgTypedStatusEffect

const DURATION: int = 40

var _ticks: int = 0

func _init() -> void:
	super(&"silenced", 1)

func tick() -> void:
	_ticks += 1
	if _ticks >= DURATION:
		remove()

func modify_stacks(s: int) -> void:
	super(s)
	_ticks = 0
