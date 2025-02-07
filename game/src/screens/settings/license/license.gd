# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control


@onready var license_dialog: AcceptDialog = %LicenseDialog
@onready var third_party_license_dialog: AcceptDialog = %ThirdPartyLicenseDialog


func _on_license_button_pressed() -> void:
	license_dialog.show()


func _on_third_party_license_button_pressed() -> void:
	third_party_license_dialog.show()

