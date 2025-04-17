# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SwitchOptionButton
extends MarginContainer

signal item_selected(index: int)

@export var disabled: bool = false

@onready var option_button: OptionButton = %OptionButton
@onready var prev_button: Button = %Prev
@onready var next_button: Button = %Next


func setup(items: Array[Variant], selected: int = 0) -> void:
	option_button.clear()
	for item: Variant in items:
		var string: String = item
		option_button.add_item(tr(string))
	option_button.selected = selected

	option_button.disabled = disabled
	prev_button.disabled = disabled
	next_button.disabled = disabled

	if not tooltip_text.is_empty():
		option_button.tooltip_text = tr(tooltip_text)
		prev_button.tooltip_text = tr(tooltip_text)
		next_button.tooltip_text = tr(tooltip_text)
	else:
		option_button.tooltip_text = option_button.text


func _on_next_pressed() -> void:
	if option_button.selected < option_button.item_count - 1:
		option_button.selected += 1
	else:
		option_button.selected = 0
	item_selected.emit(option_button.selected)
	option_button.tooltip_text = option_button.text


func _on_prev_pressed() -> void:
	if option_button.selected > 0:
		option_button.selected -= 1
	else:
		option_button.selected = option_button.item_count - 1
	item_selected.emit(option_button.selected)
	option_button.tooltip_text = option_button.text


func _on_option_button_item_selected(index: int) -> void:
	item_selected.emit(index)
	SoundUtil.play_button_sfx()
	option_button.tooltip_text = option_button.text

