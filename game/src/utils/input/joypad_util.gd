# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

enum Type {
	PLAYSTATION,
	XBOX,
	NINTENDO,
	STEAM,
	GENERIC,
}

signal joypad_changed

var joypads: Dictionary
var active_joypad: Dictionary


func _ready() -> void:
	joypads = {}
	Input.joy_connection_changed.connect(_on_joypad_connected)


func get_joypad_type_string() -> String:
	if not joypads.is_empty():
		_set_active()
		return Type.keys()[active_joypad.type]
	return "NO_JOYPAD_CONNECTED"


func get_button_sign(button: JoyButton) -> String:
	if active_joypad:
		if button in Mapping.BUTTON_GLYPHS[active_joypad.type]:
			return Mapping.BUTTON_GLYPHS[active_joypad.type][button]
	return ""


func get_axis_sign(axis: JoyAxis) -> String:
	if active_joypad:
		if axis in Mapping.AXIS_GLYPHS[active_joypad.type]:
			return Mapping.AXIS_GLYPHS[active_joypad.type][axis]
	return ""


func get_button_icon(button: JoyButton) -> Texture:
	if active_joypad:
		if button in Mapping.BUTTON_ICONS[active_joypad.type]:
			return Mapping.BUTTON_ICONS[active_joypad.type][button]
	return null


func get_axis_icon(axis: JoyAxis) -> Texture:
	if active_joypad:
		if axis in Mapping.AXIS_ICONS[active_joypad.type]:
			return Mapping.AXIS_ICONS[active_joypad.type][axis]
	return null


func currency(input_event: InputEvent) -> String:
	if active_joypad:
		if input_event is InputEventJoypadButton:
			var joypad_button: InputEventJoypadButton = input_event as InputEventJoypadButton
			return Mapping.BUTTON_GLYPHS[active_joypad.type][joypad_button.button_index]
		elif input_event is InputEventJoypadMotion:
			var joypad_motion: InputEventJoypadMotion = input_event as InputEventJoypadMotion
			return Mapping.AXIS_GLYPHS[active_joypad.type][joypad_motion.axis]
	return ""


func _on_joypad_connected(device: int, connected: bool) -> void:
	_register_joypad(device, connected)
	joypad_changed.emit()


func _register_joypad(id: int, connected: bool) -> void:
	var info: Dictionary = Input.get_joy_info(id)
	if connected:
		# check if can and should be ignored
		if _should_be_ignored(info):
			return
		
		# register joypad
		joypads[id] = {
			"info": info,
			"type": _guess_type(info),
		}
		_set_active()
		print("joypad connected id: %d info: %s"%[id, info])
	else:
		print("joypad disconnected id %d"%id)
		_set_active()
		joypads.erase(id)


# _guess_type and _should_be_ignored currently supported only on Linux
# Windows support PR here https://github.com/godotengine/godot/pull/91539
func _guess_type(info: Dictionary) -> Type:
	if "raw_name" in info:
		var raw_name: String = info.raw_name
		raw_name = raw_name.to_lower()

		if "sony" in raw_name:
			return Type.PLAYSTATION
		if "microsoft" in raw_name:
			return Type.XBOX
		if "nintendo" in raw_name:
			return Type.NINTENDO
		if "steam" in raw_name:
			return Type.STEAM

	return Type.GENERIC


func _should_be_ignored(info: Dictionary) -> bool:
	if "vendor_id" in info and "product_id" in info:
		var ignore_device: bool = Input.should_ignore_device(info.vendor_id, info.product_id)
		if ignore_device:
			print("joypad ignored info: %s"%info)
			return true
	return false


func _set_active() -> void:
	if not joypads.is_empty():
		active_joypad = joypads.values()[0]
	else:
		active_joypad = {}
