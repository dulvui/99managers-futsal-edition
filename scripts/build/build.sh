#!/bin/bash
# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: CC0-1.0

echo "Checking if .env exists..."
if [ -f ".env" ]; then
    source .env
else
    echo "File .env not found."
    echo "Exit build."
    exit 1
fi
echo "Checking if .env exists done."

echo "Building..."

mkdir builds

echo "Building Linux..."
cp $GAME_PATH/export_presets.linux.example $GAME_PATH/export_presets.cfg
$GODOT_PATH --headless --path $GAME_PATH --export-release "Linux/X11" "$PWD/builds/$GAME_NAME-linux.x86_64"
echo "Building Linux done."

echo "Building Windows..."
cp $GAME_PATH/export_presets.windows.example $GAME_PATH/export_presets.cfg
$GODOT_PATH --headless --path $GAME_PATH --export-release "Windows Desktop" "$PWD/builds/$GAME_NAME-windows.exe"
echo "Building Windows done."

echo "Cleaning up..."
rm $GAME_PATH/export_presets.cfg
echo "Cleaning up done."

echo "Building done."


