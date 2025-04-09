# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

enum AudioBus {
	UI_SFX,
	MATCH_SFX,
}

# in decibel, dont start with 100%
const DEFAULT_VOLUME: float = -24.0

var button_press: AudioStreamPlayer


func _ready() -> void:
	# create audio buses
	for bus_id: int in AudioBus.values():
		# initialize global config, if not yet done
		if not Global.config.audio.has(bus_id):
			Global.config.audio[bus_id] = {
				"mute": false,
				"volume": DEFAULT_VOLUME,
			}

		var bus_name: String = AudioBus.keys()[bus_id]
		AudioServer.add_bus(bus_id)
		AudioServer.set_bus_name(bus_id, bus_name)
		var mute: bool = Global.config.audio[bus_id].mute
		AudioServer.set_bus_mute(bus_id, mute)
		var volume: float = Global.config.audio[bus_id].volume
		AudioServer.set_bus_volume_db(bus_id, volume)

	# button press sfx
	button_press = AudioStreamPlayer.new()
	add_child(button_press)
	button_press.stream = load("res://assets/audio/switch_001.ogg")
	button_press.bus = AudioServer.get_bus_name(AudioBus.UI_SFX)


func set_bus_volume(bus_id: AudioBus, volume: float) -> void:
	Global.config.audio[bus_id].volume = volume
	AudioServer.set_bus_volume_db(bus_id, volume)
	print(AudioServer.get_bus_volume_db(bus_id))
	DataUtil.save_config()


func get_bus_volume(bus_id: AudioBus) -> float:
	return Global.config.audio[bus_id].volume


func set_bus_mute(bus_id: AudioBus, mute: bool) -> void:
	Global.config.audio[bus_id].mute = mute
	AudioServer.set_bus_mute(bus_id, mute)
	print("mute bus id: %d" % bus_id)
	DataUtil.save_config()


func get_bus_mute(bus_id: AudioBus) -> bool:
	return Global.config.audio[bus_id].mute


func play_button_sfx() -> void:
	if Global.config.audio[AudioBus.UI_SFX].mute:
		return
	button_press.play()


func restore_default() -> void:
	for bus_id: int in AudioBus.values():
		# initialize global config, if not yet done
		Global.config.audio[bus_id] = {
			"mute": false,
			"volume": DEFAULT_VOLUME,
		}
