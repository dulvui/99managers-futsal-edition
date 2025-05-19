# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name LoadingScreen
extends Control

var message: String
var progress: float
var indeterminate: bool

@onready var loading_progress_bar: ProgressBar = %LoadingProgressBar
@onready var message_label: Label = %Message


func _ready() -> void:
	progress = 0
	loading_progress_bar.value = 0


func _process(delta: float) -> void:
	loading_progress_bar.value = lerpf(loading_progress_bar.value, progress, delta * 5)


func start(p_message: String, p_indeterminate: bool = false) -> void:
	message = p_message
	indeterminate = p_indeterminate
	progress = 0
	loading_progress_bar.value = 0


func update(p_progress: float) -> void:
	progress = p_progress

