# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends VBoxContainer
class_name CustomTabContainer

var active_tab: int
var max_tab: int
var buttons: Array[DefaultButton]
var views: Array[Control]

@onready var buttons_container: HBoxContainer = %Buttons
@onready var buttons_bar: HBoxContainer = %ButtonsBar


func _ready() -> void:
	active_tab = 0
	max_tab = get_child_count() - 1

	# setup tab button bar
	var button_group: ButtonGroup = ButtonGroup.new()
	for child: Control in get_children():
		if child == buttons_bar:
			continue
		var tab_name: String = child.name
		var button: DefaultButton = DefaultButton.new()
		button.text = tr(tab_name)
		button.pressed.connect(_on_button_pressed.bind(views.size()))
		button.button_group = button_group
		button.toggle_mode = true

		buttons_container.add_child(button)
		buttons.append(button)

		child.hide()
		views.append(child)

	# press first button
	if buttons.size() > 0:
		var first_button: DefaultButton = buttons[active_tab]
		first_button.pressed.emit()


func _on_button_pressed(index: int = active_tab) -> void:
	active_tab = index
	_show_active()


func _on_next_pressed() -> void:
	active_tab += 1
	_check_bounds()
	_show_active()


func _on_prev_pressed() -> void:
	active_tab -= 1
	_check_bounds()
	_show_active()


func _check_bounds() -> void:
	if active_tab >= max_tab:
		active_tab = 0
	elif active_tab < 0:
		active_tab = max_tab - 1


func _show_active() -> void:
	if views.is_empty():
		return

	for view: Control in views:
		view.hide()

	views[active_tab].show()
	buttons[active_tab].button_pressed = true

