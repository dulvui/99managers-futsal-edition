# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneralSettings
extends VBoxContainer

enum ColorType {
	FONT,
	STYLE,
	BACKGROUND,
}

var active_color_type: ColorType

@onready var theme_options: OptionButton = %ThemeOptionButton
@onready var ui_sfx_volume: HSlider = %UISfxVolumeSlider
@onready var version_label: Label = %VersionLabel
@onready var font_size_spinbox: SpinBox = %FontSizeSpinBox
@onready var color_picker_popup: PopupPanel = $ColorPopupPanel
@onready var color_picker: ColorPicker = $ColorPopupPanel/MarginContainer/ColorPicker
@onready var screen_fade_button: CheckButton = %ScreenFadeButton


func _ready() -> void:
	font_size_spinbox.value = Global.config.theme_font_size
	font_size_spinbox.min_value = Const.FONT_SIZE_MIN
	font_size_spinbox.max_value = Const.FONT_SIZE_MAX

	for theme_name: String in ThemeUtil.get_theme_names():
		theme_options.add_item(theme_name)
	theme_options.selected = Global.config.theme_index

	version_label.text = "v" + Global.version
	
	ui_sfx_volume.value = SoundUtil.get_bus_volume(SoundUtil.AudioBus.UI_SFX)
	screen_fade_button.button_pressed = Global.config.scene_fade


func restore_defaults() -> void:
	# font size
	Global.config.theme_font_size = Const.FONT_SIZE_DEFAULT
	font_size_spinbox.value = Global.config.theme_font_size
	# theme
	ThemeUtil.reset_to_default()
	theme_options.selected = 0
	#scale
	Global.config.theme_scale = ThemeUtil.get_default_scale()
	get_tree().root.content_scale_factor = Global.config.theme_scale
	# audio
	SoundUtil.restore_default()
	ui_sfx_volume.value = SoundUtil.get_bus_volume(SoundUtil.AudioBus.UI_SFX)
	# scene fade
	Global.config.scene_fade = true
	screen_fade_button.button_pressed = true


func _on_theme_option_button_item_selected(index: int) -> void:
	var theme_name: String = theme_options.get_item_text(index)
	ThemeUtil.apply_theme(theme_name)
	Global.config.theme_index = index
	ResUtil.save_config()


func _on_font_default_button_pressed() -> void:
	Global.config.theme_font_size = Const.FONT_SIZE_DEFAULT
	font_size_spinbox.value = Global.config.theme_font_size
	ThemeUtil.reload_active_theme()
	ResUtil.save_config()


func _on_font_size_spin_box_value_changed(value: float) -> void:
	Global.config.theme_font_size = int(value)
	ThemeUtil.reload_active_theme()
	ResUtil.save_config()


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
	print(color)
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


func _on_scale_1_pressed() -> void:
	get_tree().root.content_scale_factor = Const.SCALE_1
	Global.config.theme_scale = Const.SCALE_1
	ResUtil.save_config()


func _on_scale_2_pressed() -> void:
	get_tree().root.content_scale_factor = Const.SCALE_2
	Global.config.theme_scale = Const.SCALE_2
	ResUtil.save_config()


func _on_scale_3_pressed() -> void:
	get_tree().root.content_scale_factor = Const.SCALE_3
	Global.config.theme_scale = Const.SCALE_3
	ResUtil.save_config()


func _on_screen_fade_button_toggled(toggled_on: bool) -> void:
	Global.config.scene_fade = toggled_on
	ResUtil.save_config()


func _on_ui_sfx_volume_slider_drag_ended(value_changed:bool) -> void:
	if value_changed:
		SoundUtil.set_bus_volume(SoundUtil.AudioBus.UI_SFX, ui_sfx_volume.value)
		SoundUtil.set_bus_mute(SoundUtil.AudioBus.UI_SFX, ui_sfx_volume.value == ui_sfx_volume.min_value)
		SoundUtil.play_button_sfx()
		ResUtil.save_config()

