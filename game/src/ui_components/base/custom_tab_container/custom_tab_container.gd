# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends VBoxContainer
class_name CustomTabContainer

var active_tab: int
var tab_count: int

@onready var content: Control = %Content
@onready var buttons: HBoxContainer = %Buttons



func _ready() -> void:
	active_tab = 0
	tab_count = content.get_child_count()

	# setup tab button bar
	for child: Control in content.get_children():
		var tab_name: String = child.name
		var button: DefaultButton = DefaultButton.new()
		button.text = tr(tab_name)
		button.pressed.connect(_on_tab_clicked.bind(child))
		buttons.add_child(button)
		child.hide()

	# show first child
	var child: Control = content.get_child(0)
	if child != null:
		child.show()

	# first button grab focus
	var first_button: DefaultButton = buttons.get_children()[active_tab]
	first_button.grab_focus()


func _on_tab_clicked(p_child: Control) -> void:
	var children: Array[Node] = content.get_children()
	for child: Control in children:
		child.visible = child == p_child

	active_tab = children.find(p_child)


func _on_next_pressed() -> void:
	active_tab += 1
	_show_active()


func _on_prev_pressed() -> void:
	active_tab -= 1
	_show_active()


func _show_active() -> void:
	if active_tab > tab_count - 1:
		active_tab = 1
	if active_tab < 0:
		active_tab = tab_count - 1

	var button: DefaultButton = buttons.get_children()[active_tab]
	button.grab_focus()
	button.pressed.emit()

