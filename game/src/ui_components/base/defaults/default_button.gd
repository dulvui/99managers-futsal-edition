# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultButton
extends Button

@export var key_event: InputEventKey
@export var joypad_button_event: InputEventJoypadButton
@export var joypad_motion_event: InputEventJoypadMotion


func _ready() -> void:
	if tooltip_text.is_empty() and text.length() > 1:
		tooltip_text = text

	icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	expand_icon = true
	shortcut_in_tooltip = false

	_setup_shortcuts()
	_set_shortcut_glyph()
	_set_alignment()

	InputUtil.type_changed.connect(_on_input_type_changed)


func _pressed() -> void:
	SoundUtil.play_button_sfx()


func _setup_shortcuts() -> void:
	shortcut = Shortcut.new()

	if joypad_button_event:
		shortcut.events.append(joypad_button_event)
	if joypad_motion_event:
		shortcut.events.append(joypad_motion_event)
	if key_event:
		shortcut.events.append(key_event)


func _set_shortcut_glyph() -> void:
	if InputUtil.type == Enum.InputType.JOYPAD and joypad_button_event:
		icon = JoypadUtil.get_button_icon(joypad_button_event.button_index)
	elif InputUtil.type == Enum.InputType.JOYPAD and joypad_motion_event:
		icon = JoypadUtil.get_axis_icon(joypad_motion_event.axis)

		# workaround until not fixed https://github.com/godotengine/godot/issues/99331
		if joypad_motion_event.axis == JOY_AXIS_TRIGGER_LEFT:
			JoypadAxisUtil.l2.connect(func() -> void: pressed.emit())
		if joypad_motion_event.axis == JOY_AXIS_TRIGGER_RIGHT:
			JoypadAxisUtil.r2.connect(func() -> void: pressed.emit())
	elif InputUtil.type == Enum.InputType.MOUSE_AND_KEYBOARD and key_event:
		# workaround for /
		if key_event.as_text() == "Slash":
			text = "/" # NO_TRANSLATE
		else:
			text = key_event.as_text()

		icon = null
	else:
		icon = null


func _set_alignment() -> void:
	# don't align left on single caracters buttons or number buttons
	if text.length() == 1 or text.is_valid_int():
		alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		alignment = HORIZONTAL_ALIGNMENT_LEFT


func _on_input_type_changed(_type: Enum.InputType) -> void:
	_set_shortcut_glyph()
	_set_alignment()
