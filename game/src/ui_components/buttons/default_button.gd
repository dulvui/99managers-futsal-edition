# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultButton
extends Button


@export var key_event: InputEventKey
@export var joypad_button_event: InputEventJoypadButton
@export var joypad_motion_event: InputEventJoypadMotion


func _ready() -> void:
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
	if key_event:
		shortcut.events.append(key_event)


func _set_shortcut_glyph() -> void:
	if InputUtil.type == InputUtil.Type.JOYPAD and joypad_button_event:
		icon = JoypadUtil.get_button_icon(joypad_button_event.button_index)
		# text = tooltip_text + " %s"%JoypadUtil.get_button_sign(joypad_button_event.button_index)
		# text = tooltip_text
	elif InputUtil.type == InputUtil.Type.KEYBOARD and key_event: 
		# text = tooltip_text + " " + key_event.as_text()
		icon = null
	else:
		icon = null
	

func _set_alignment() -> void:
	# don't align left on single caracters buttons or number buttons
	if text.length() == 1 or text.is_valid_int():
		alignment = HORIZONTAL_ALIGNMENT_CENTER
	elif InputUtil.type == InputUtil.Type.JOYPAD:
		alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		alignment = HORIZONTAL_ALIGNMENT_CENTER


func _on_input_type_changed(_type: InputUtil.Type) -> void:
	_set_shortcut_glyph()
	_set_alignment()


