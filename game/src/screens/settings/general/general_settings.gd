# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneralSettings
extends VBoxContainer

# audio
@onready var ui_sfx_volume: HSlider = %UISfxVolumeSlider
# ui
@onready var font_size_spinbox: SpinBox = %FontSizeSpinBox
@onready var screen_fade_button: CheckButton = %ScreenFadeButton
@onready var theme_picker: ThemePicker = %ThemePicker
# scale
@onready var scale_button_1: DefaultButton = %Scale1
@onready var scale_button_2: DefaultButton = %Scale2
@onready var scale_button_3: DefaultButton = %Scale3
# formats
@onready var date_button: SwitchOptionButton = %DatesOptionsButton
@onready var currency_button: SwitchOptionButton = %CurrenciesOptionsButton
@onready var formats_example_label: Label = %FormatsExample
# generic
@onready var version_label: Label = %VersionLabel


func _ready() -> void:
	# audio
	ui_sfx_volume.value = SoundUtil.get_bus_volume(SoundUtil.AudioBus.UI_SFX)
	# ui
	font_size_spinbox.value = Global.config.theme_font_size
	font_size_spinbox.min_value = Const.FONT_SIZE_MIN
	font_size_spinbox.max_value = Const.FONT_SIZE_MAX
	screen_fade_button.button_pressed = Global.config.scene_fade
	# scale
	scale_button_1.button_pressed = Global.config.theme_scale == Const.SCALE_1
	scale_button_2.button_pressed = Global.config.theme_scale == Const.SCALE_2
	scale_button_3.button_pressed = Global.config.theme_scale == Const.SCALE_3
	# formats
	date_button.setup(FormatUtil.DATES_EXAMPLES, Global.config.date)
	currency_button.setup(FormatUtil.SIGNS_TEXT, Global.config.currency)
	formats_example_label.text = "%s %s" % [
		FormatUtil.date(31, 12, 2000), FormatUtil.currency(1234)
	]
	# generic
	version_label.text = "v" + Global.version


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


func _on_translations_link_meta_clicked(_meta: Variant) -> void:
	SoundUtil.play_button_sfx()
	OS.shell_open("https://hosted.weblate.org/projects/99-managers-futsal-edition/game/")


func _on_currencies_options_button_item_selected(index: int) -> void:
	Global.config.currency = index as FormatUtil.Currencies
	formats_example_label.text = "%s %s" % [
		FormatUtil.date(31, 12, 2000), FormatUtil.currency(1234)
	]
	DataUtil.save_config()


func _on_dates_options_button_item_selected(index: int) -> void:
	Global.config.date = index as FormatUtil.Dates
	formats_example_label.text = "%s %s" % [
		FormatUtil.date(31, 12, 2000), FormatUtil.currency(1234)
	]
	DataUtil.save_config()

