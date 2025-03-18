<!--
SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

SPDX-License-Identifier: CC0-1.0
-->

# Wiktionary name downloader
This script downloads all female, male and surnames for given languages from [Wiktionary](https://en.wiktionary.org).
It uses the Wiktionary's [MediaWiki API](https://en.wiktionary.org/w/api.php?) to get machine readable content.

The result is saved in simple csv files with the request URL in the first line as a comment.  
Here an example result for English female names
```csv
# https://en.wiktionary.org/w/api.php?action=query&list=categorymembers&cmtitle=Category%3AEnglish_female_given_names&cmlimit=max&format=json
Aadhya
Aafia
Aaliyah
Aanya
Aarah
Aaralyn
# file goes on...
```

# Execute
The python script has no external dependencies, so you can simply run it.
```bash
python3 wiktionary-name-downloader.py
```

Then move the result to the player_names data directory.
```bash
cp *.csv ../../game/data/player_names/
```
