#!/bin/bash
# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

for file in ../../translations/*.csv; do
    tail -n +2 "$file" > "../../game/translations/$(basename "$file")"
done
