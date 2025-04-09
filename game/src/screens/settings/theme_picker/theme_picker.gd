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

@export var show_custom: bool = true

@onready var options: SwitchOptionButton = %OptionButton
@onready var custom: VBoxContainer = %Custom
@onready var color_picker_popup: PopupPanel = %ColorPopupPanel
@onready var color_picker: ColorPicker = %ColorPicker


func _ready() -> void:
	options.setup(ThemeUtil.get_theme_names(show_custom), Global.config.theme_index)

	custom.visible = show_custom


func _on_option_button_item_selected(index: int) -> void:
	Main.apply_theme(index)
	Global.config.theme_index = index
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
