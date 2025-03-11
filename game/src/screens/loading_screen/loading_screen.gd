# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name LoadingScreen
extends Control

signal loaded

@onready var loading_progress_bar: ProgressBar = $VBoxContainer/LoadingProgressBar
@onready var message_label: Label = $VBoxContainer/Message


func _ready() -> void:
	loading_progress_bar.indeterminate = LoadingUtil.indeterminate
	# connect loaded signal also here
	LoadingUtil.loaded.connect(_loaded)


func _process(_delta: float) -> void:
	if not LoadingUtil.indeterminate:
		message_label.text = LoadingUtil.message
		loading_progress_bar.value = LoadingUtil.progress


func _loaded() -> void:
	hide()
	loaded.emit()


func _on_visibility_changed() -> void:
	if is_node_ready() and visible:
		loading_progress_bar.value = 0
		loading_progress_bar.indeterminate = LoadingUtil.indeterminate
		message_label.text = LoadingUtil.message
		loading_progress_bar.value = LoadingUtil.progress
