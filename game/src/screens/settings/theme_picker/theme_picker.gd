# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ThemePicker
extends VBoxContainer

enum ColorType {
	FONT,
	STYLE,
	BACKGROUND,
}

var active_color_type: ColorType
var buttons: Array[Button]

@export var show_custom: bool = true

@onready var themes: HFlowContainer = %Themes
@onready var custom: VBoxContainer = %Custom
@onready var color_picker_popup: PopupPanel = %ColorPopupPanel
@onready var color_picker: ColorPicker = %ColorPicker


func _ready() -> void:
	setup()


func setup() -> void:
	# clear buttons
	for child: Node in themes.get_children():
		child.queue_free()

	# create buttons
	var button_group: ButtonGroup = ButtonGroup.new()
	var index: int = 0
	for theme_name: String in ThemeUtil.get_theme_names(show_custom):
		var button: Button = DefaultButton.new()
		button.text = tr(theme_name)
		button.button_group = button_group
		button.toggle_mode = true
		# toggle active themes
		button.button_pressed = index == Global.config.theme_index
		button.pressed.connect(_on_button_pressed.bind(index))
		themes.add_child(button)
		index += 1

	custom.visible = show_custom


func _on_button_pressed(index: int) -> void:
	Global.config.theme_index = index
	Main.apply_theme(index)
	DataUtil.save_config()


func _on_font_color_button_pressed() -> void:
	active_color_type = ColorType.FONT
	color_picker.color = Global.config.theme_custom_font_color
	color_picker_popup.popup_centered()


func _on_style_color_button_pressed() -> void:
	active_color_type = ColorType.STYLE
	color_picker.color = Global.config.theme_custom_style_color
	color_picker_popup.popup_centered()


func _on_background_color_button_pressed() -> void:
	active_color_type = ColorType.BACKGROUND
	color_picker.color = Global.config.theme_custom_background_color
	color_picker_popup.popup_centered()


func _on_close_color_picker_button_pressed() -> void:
	color_picker_popup.hide()


func _on_color_picker_color_changed(color: Color) -> void:
	match active_color_type:
		ColorType.FONT:
			Global.config.theme_custom_font_color = color.to_html(true)
		ColorType.STYLE:
			Global.config.theme_custom_style_color = color.to_html(true)
		ColorType.BACKGROUND:
			Global.config.theme_custom_background_color = color.to_html(true)
		_:
			print("color type not defined")

	if ThemeUtil.is_custom_theme():
		ThemeUtil.reload_active_theme()
