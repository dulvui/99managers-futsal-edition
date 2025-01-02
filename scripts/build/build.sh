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


echo "Update version to current date..."

# create backup of project.godot file
cp $GAME_PATH/project.godot $GAME_PATH/project.godot.backup

DATE=$(date +%Y%m%d%H%M)
echo $DATE
sed -i 's;config/version="development";config/version="'$DATE'";' $GAME_PATH/project.godot

echo "Update version to current date done."

echo "Building..."

rm -rf builds
mkdir builds
mkdir builds/linux
mkdir builds/windows
mkdir builds/macos

echo "Building Linux..."
cp $GAME_PATH/export_presets.linux.example $GAME_PATH/export_presets.cfg
$GODOT_PATH --headless --path $GAME_PATH --export-release "Linux/X11" "$PWD/builds/linux/$GAME_NAME-linux.x86_64"
zip -r $PWD/builds/99managers-futsal-edition-linux.zip $PWD/builds/linux/
echo "Building Linux done."

echo "Building Windows..."
cp $GAME_PATH/export_presets.windows.example $GAME_PATH/export_presets.cfg
$GODOT_PATH --headless --path $GAME_PATH --export-release "Windows Desktop" "$PWD/builds/windows/$GAME_NAME-windows.exe"
zip -r $PWD/builds/99managers-futsal-edition-windows.zip $PWD/builds/windows/
echo "Building Windows done."

echo "Building MacOS..."
cp $GAME_PATH/export_presets.macos.example $GAME_PATH/export_presets.cfg
$GODOT_PATH --headless --path $GAME_PATH --export-release "macOS" "$PWD/builds/macos/$GAME_NAME-macos.app"
zip -r $PWD/builds/99managers-futsal-edition-macos.zip $PWD/builds/macos/
echo "Building MacOS done."

echo "Cleaning up..."
rm $GAME_PATH/export_presets.cfg
# restore backup
mv $GAME_PATH/project.godot.backup $GAME_PATH/project.godot
echo "Cleaning up done."

echo "Building done."


