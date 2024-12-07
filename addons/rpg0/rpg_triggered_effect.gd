class_name RpgTriggeredEffect extends Object

var turn_start_callback: Callable
var turn_end_callback: Callable
var tick_callback: Callable
var hp_change_callback: Callable
#var any_skill_used_callback: Callable # TODO

var _connections: Dictionary

func connect_all(character: RpgCharacter) -> void:
	if turn_start_callback:
		_add_connection(character.turn_started, turn_start_callback)
	if turn_end_callback:
		_add_connection(character.turn_ended, turn_end_callback)
	if tick_callback:
		_add_connection(character.ticked, tick_callback)
	if hp_change_callback:
		_add_connection(character.hp_changed, hp_change_callback)

func disconnect_all() -> void:
	for callback in _connections.keys():
		_connections[callback].disconnect(callback)

func _add_connection(s: Signal, c: Callable) -> void:
	s.connect(c)
	_connections[c] = s
