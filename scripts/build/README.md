<!--
SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

SPDX-License-Identifier: CC0-1.0
-->

# Build
The scripts in this directory are sued to build the game for various platforms.
This can be used for local building, but theoretically also in a CI job.

The main goal of this is to move away from Github Actions and make a more git platform independent build system.


# Environment variables
Create a copy of the `.env.example` file and fill it.
```bash
cp .env.example .env
```
