#!/bin/bash
# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

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
echo "Building Linux done."

echo "Creating Linux archive..."
pushd builds/linux/
zip -r ../../99managers-futsal-edition-linux.zip .
popd
echo "Creating Linux archive done."

echo "Building Windows..."
cp $GAME_PATH/export_presets.windows.example $GAME_PATH/export_presets.cfg
$GODOT_PATH --headless --path $GAME_PATH --export-release "Windows Desktop" "$PWD/builds/windows/$GAME_NAME-windows.exe"
echo "Building Windows done."

echo "Creating Windows archive..."
pushd builds/windows/
zip -r ../../99managers-futsal-edition-windows.zip .
popd
echo "Creating Windows archive done."

echo "Building MacOS..."
cp $GAME_PATH/export_presets.macos.example $GAME_PATH/export_presets.cfg
$GODOT_PATH --headless --path $GAME_PATH --export-release "macOS" "$PWD/builds/macos/$GAME_NAME-macos.app"
echo "Building MacOS done."

echo "Creating MacOS archive..."
pushd builds/macos/
zip -r ../../99managers-futsal-edition-macos.zip .
popd
echo "Creating MacOS archive done."

echo "Cleaning up..."
rm $GAME_PATH/export_presets.cfg
# restore backup
mv $GAME_PATH/project.godot.backup $GAME_PATH/project.godot
echo "Cleaning up done."

echo "Building done."


