# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends MarginContainer

const WEBLATE_URL: StringName = "https://hosted.weblate.org/user/"
const CONTRIBUTORS: Array[StringName] = [
	"VictorGavilanes",
	"Kefir2105",
	"Atalanttore",
	"cyphra",
	"Ekselius",
	"maksimgorpinic2005a",
	"Alkaf.2018",
	"joaocaruco77",
	"PizzaParty",
	"mahmoud",
	"Alkaf.2018",
	"ssantos",
	"Catmayo",
	"oyekbudin",
]

@onready var list: VBoxContainer = %TranslatorsList


func _ready() -> void:
	for contributor: StringName in CONTRIBUTORS:
		var link_button: LinkButton = LinkButton.new()
		link_button.text = contributor
		link_button.uri = WEBLATE_URL + contributor
		link_button.tooltip_text = WEBLATE_URL + contributor
		list.add_child(link_button)
