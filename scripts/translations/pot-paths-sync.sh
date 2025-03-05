#!/bin/bash
# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

path="../../game/src/"

# add paths and files to exclude
exclude=("../game/src/media/**")

# Add exclusions to the find command
# for file in "${exclude[@]}"; do
#     find_command+=" ! -wholename '$file'"
# done

find_command() {
    find ../../game/src/ -type f \( -name '*.gd' -o -name '*.tscn' ! -wholename '../game/src/media/**' \)
}

paths=find_command

echo find_command
echo $paths

printf $paths '"%s", ' {} + | sed "s;$paths;res://src/;" > paths
