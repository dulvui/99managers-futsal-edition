# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal type_changed(type: Type)


const DETECTION_TIMEOUT: int = 3

enum DetectionMode {
	AUTO,
	MANUAL,
}

enum Type {
	JOYPAD,
	KEYBOARD,
	#VIRTUAL_KEYBOARD,
	TOUCH,
}

var focused: bool
var viewport: Viewport
var first_focus: Control
var last_focus: Control
var type: Type:
	set = set_type

# to prevent constant type switches on detection mode auto
var timer: Timer


func _ready() -> void:
	focused = true
	
	viewport = get_viewport()
	viewport.gui_focus_changed.connect(_on_gui_focus_change)

	timer = Timer.new()
	add_child(timer)
	
	type = Global.input_type


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focused = true


func _input(event: InputEvent) -> void:
	if focused:
		
		# only verify focus, when pressed
		if event.is_pressed():
			_verify_focus()

		_verify_type(event)
		
		JoypadAxisUtil.handle_event(event)

		return
	else:
		viewport.set_input_as_handled()


func start_focus(node: Control) -> void:
	first_focus = node
	# check if control can't be focused
	if node.focus_mode == node.FOCUS_NONE:
		# find next control to focus
		first_focus = node.find_next_valid_focus()
	
	if first_focus:
		first_focus.grab_focus()
	else:
		print("start focus: not node found to focus")


func set_type(p_type: Type) -> void:
	type = p_type
	Global.input_type = type
	type_changed.emit(type)

	timer.start(DETECTION_TIMEOUT)


func _verify_focus() -> void:
	# check if a nodes has focus, if not, last or first focused node grabs it
	if viewport.gui_get_focus_owner() == null:
		if last_focus != null and last_focus.is_inside_tree():
			print("regrab last focus")
			last_focus.grab_focus()
		elif first_focus != null and first_focus.is_inside_tree():
			first_focus.grab_focus()
		else:
			print("not able to regrab focus")


func _verify_type(event: InputEvent) -> void:
	if Global.input_detection_mode == DetectionMode.MANUAL:
		return

	if timer.time_left > 0.5:
		return

	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if type != Type.JOYPAD:
			type = Type.JOYPAD
	elif event is InputEventKey or event is InputEventMouse:
		if type != Type.KEYBOARD:
			type = Type.KEYBOARD


func _on_gui_focus_change(node: Control) -> void:
	last_focus = node
