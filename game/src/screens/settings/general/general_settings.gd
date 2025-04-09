# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneralSettings
extends VBoxContainer

@onready var ui_sfx_volume: HSlider = %UISfxVolumeSlider
@onready var version_label: Label = %VersionLabel
@onready var font_size_spinbox: SpinBox = %FontSizeSpinBox
@onready var screen_fade_button: CheckButton = %ScreenFadeButton
@onready var theme_picker: ThemePicker = %ThemePicker
@onready var scale_button_1: DefaultButton = %Scale1
@onready var scale_button_2: DefaultButton = %Scale2
@onready var scale_button_3: DefaultButton = %Scale3


func _ready() -> void:
	font_size_spinbox.value = Global.config.theme_font_size
	font_size_spinbox.min_value = Const.FONT_SIZE_MIN
	font_size_spinbox.max_value = Const.FONT_SIZE_MAX

	version_label.text = "v" + Global.version

	ui_sfx_volume.value = SoundUtil.get_bus_volume(SoundUtil.AudioBus.UI_SFX)
	screen_fade_button.button_pressed = Global.config.scene_fade

	scale_button_1.button_pressed = Global.config.theme_scale == Const.SCALE_1
	scale_button_2.button_pressed = Global.config.theme_scale == Const.SCALE_2
	scale_button_3.button_pressed = Global.config.theme_scale == Const.SCALE_3


func restore_defaults() -> void:
	# font size
	Global.config.theme_font_size = Const.FONT_SIZE_DEFAULT
	font_size_spinbox.value = Global.config.theme_font_size
	# theme
	ThemeUtil.reset_to_default()
	theme_picker.options.option_button.selected = 0
	#scale
	Global.config.theme_scale = ThemeUtil.get_default_scale()
	get_tree().root.content_scale_factor = Global.config.theme_scale
	# audio
	SoundUtil.restore_default()
	ui_sfx_volume.value = SoundUtil.get_bus_volume(SoundUtil.AudioBus.UI_SFX)
	# scene fade
	Global.config.scene_fade = true
	screen_fade_button.button_pressed = true


func _on_font_default_button_pressed() -> void:
	Global.config.theme_font_size = Const.FONT_SIZE_DEFAULT
	font_size_spinbox.value = Global.config.theme_font_size
	ThemeUtil.reload_active_theme()
	DataUtil.save_config()


func _on_font_size_spin_box_value_changed(value: float) -> void:
	Global.config.theme_font_size = int(value)
	ThemeUtil.reload_active_theme()
	DataUtil.save_config()


func _on_scale_1_pressed() -> void:
	get_tree().root.content_scale_factor = Const.SCALE_1
	Global.config.theme_scale = Const.SCALE_1
	DataUtil.save_config()


func _on_scale_2_pressed() -> void:
	get_tree().root.content_scale_factor = Const.SCALE_2
	Global.config.theme_scale = Const.SCALE_2
	DataUtil.save_config()


func _on_scale_3_pressed() -> void:
	get_tree().root.content_scale_factor = Const.SCALE_3
	Global.config.theme_scale = Const.SCALE_3
	DataUtil.save_config()


func _on_screen_fade_button_toggled(toggled_on: bool) -> void:
	Global.config.scene_fade = toggled_on
	DataUtil.save_config()


func _on_ui_sfx_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		SoundUtil.set_bus_volume(SoundUtil.AudioBus.UI_SFX, ui_sfx_volume.value)
		SoundUtil.set_bus_mute(
			SoundUtil.AudioBus.UI_SFX, ui_sfx_volume.value == ui_sfx_volume.min_value
		)
		SoundUtil.play_button_sfx()
		DataUtil.save_config()
