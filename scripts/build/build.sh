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


echo "Checking if export templates exist..."
if [ -d "$HOME/.local/share/godot/export_templates/$GODOT_VERSION.stable" ]; then
    echo "Export templates are installed."
else
    echo "Downloading export templates..."
    wget "https://github.com/godotengine/godot-builds/releases/download/$GODOT_VERSION-stable/Godot_v$GODOT_VERSION-stable_export_templates.tpz"
    unzip "Godot_v$GODOT_VERSION-stable_export_templates.tpz"
    mkdir -p "$HOME/.local/share/godot/export_templates/$GODOT_VERSION.stable"
    mv templates/* "$HOME/.local/share/godot/export_templates/$GODOT_VERSION.stable"
    rm -f "Godot_v$GODOT_VERSION-stable_export_templates.tpz"
    echo "Downloading export templates done."
fi
echo "Checking if export templates exist done."


echo "Checking Godot executable exists..."
if [ ! -z "$GODOT_PATH" ]; then
    echo "GODOT_PATH is set, using that for the build."
elif [ -f "./Godot_v$GODOT_VERSION-stable_linux.x86_64" ]; then
    echo "Found godot executable here, using that for the build."
    GODOT_PATH="./Godot_v$GODOT_VERSION-stable_linux.x86_64"
else
    echo "GODOT_PATH is empty and no godot executable found..."
    echo "Downloading Godot $GODOT_VERSION executable..."
    wget "https://github.com/godotengine/godot-builds/releases/download/$GODOT_VERSION-stable/Godot_v$GODOT_VERSION-stable_linux.x86_64.zip"
    unzip "Godot_v$GODOT_VERSION-stable_linux.x86_64.zip"
    rm -f "Godot_v$GODOT_VERSION-stable_linux.x86_64.zip"
    mv "./Godot_v$GODOT_VERSION-stable_linux.x86_64"
    GODOT_PATH="./Godot_v$GODOT_VERSION-stable_linux.x86_64"
    echo "Downloading Godot executable done."
fi
echo "Checking Godot executable exists done."


echo "Building..."

rm -rf builds
mkdir builds
mkdir builds/linux
mkdir builds/windows
mkdir builds/macos

echo "Building Linux..."
cp $GAME_PATH/export_presets.linux.example $GAME_PATH/export_presets.cfg
echo "$GODOT_PATH"
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

echo "Building done."


