#!/bin/bash
# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later


grep -rho '\b[[:upper:]_]\+\b' ../game/src/ | sort | uniq > ingame_strings
grep -ho '\b[[:upper:]_]\+\b' ../game/translations/en.csv  | sort | uniq > translated_strings

grep -v -F -x -f ingame_strings translated_strings > missing_strings


