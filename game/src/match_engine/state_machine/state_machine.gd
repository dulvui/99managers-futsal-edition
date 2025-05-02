# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StateMachine

# state buffer with states name as key and count as value
const BUFFER_SIZE: int = 10
var buffer: Array[StateMachineState]
var same_state_count: int

var field: SimField

var state: StateMachineState
var previous_state: StateMachineState

var rng: RngUtil


func _init(p_rng: RngUtil, p_field: SimField) -> void:
	rng = p_rng
	field = p_field

	# initialize buffer
	buffer = []
	same_state_count = 0


func execute() -> void:
	state.execute()


func set_state(p_state: StateMachineState) -> void:
	if state:
		# don't set same states again
		if p_state.name == state.name:
			return

		# exit current and set as previous
		state.exit()
		previous_state = state

	# enter and set as current
	state = p_state
	state.enter()

	# append to buffer
	_buffer_append()


func _buffer_append() -> void:
	if buffer.size() > 0 and buffer[-1] == state:
		same_state_count += 1
	else:
		same_state_count = 1

	buffer.append(state)

	if buffer.size() > BUFFER_SIZE:
		buffer.pop_front()

