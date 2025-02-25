# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name JSONResource
extends Resource

# enum SaveStrategy {
# 	ALWAYS,
# 	MANUAL,
# }
#
# var save_strategy: SaveStrategy
#
# var has_changed: bool
# var changed_childs: Array[String]
#
# var dict_on_load: Dictionary
# var self_hash: int


func to_json() -> Dictionary:
	var data: Dictionary = {}

	# only add export vars to dictionary
	var property_list: Array[Dictionary] = get_property_list()
	for property: Dictionary in property_list:
		# only convert properties with @export annotation
		# enums have own flag
		if (
			property.usage != Const.CUSTOM_PROPERTY_EXPORT
			and property.usage != Const.CUSTOM_PROPERTY_EXPORT_ENUM
		):
			continue

		# if hash(self) == self_hash:
		# 	return dict_on_load

		var property_name: String = property.name
		var value: Variant = get(property_name)
		if value != null:
			if value is Array:
				var parsed_array: Array = []
				var array: Array = value as Array
				for item: Variant in array:
					if item is JSONResource:
						parsed_array.append((item as JSONResource).to_json())
					else:
						parsed_array.append(item)
				data[property_name] = parsed_array
			elif value is JSONResource:
				data[property_name] = (value as JSONResource).to_json()
			else:
				data[property_name] = value
	return data


func from_json(dict: Dictionary) -> void:
	# dict_on_load = dict.duplicate()
	# self_hash = hash(self)

	for key: String in dict.keys():
		var property: Variant = get(key)

		# cover edge case if firt leg of match.gd
		# first leg is null in init, so manual initialization is needed
		if key == "first_leg":
			property = Match.new()

		if property == null:
			continue

		if property is Array:
			var array: Array[Variant] = property as Array
			var dict_array: Array = dict[key]
			# assuming all used resources are JSON resources
			# could be made more precise by checking path of get_typed_script
			var array_script: GDScript = array.get_typed_script()
			if array_script != null:
				for dict_item: Variant in dict_array:
					var resource: JSONResource = array_script.new()
					resource.from_json(dict_item)
					array.append(resource)
			# built in types, without considering nested arrays
			else:
				var array_type: int = array.get_typed_builtin()
				for dict_item: Variant in dict_array:
					array.append(type_convert(dict_item, array_type))

		elif property is JSONResource:
			(property as JSONResource).from_json(dict[key])
		else:
			set(key, dict[key])
