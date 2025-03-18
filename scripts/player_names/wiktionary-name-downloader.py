# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

import http.client
import json
import urllib.parse

API_URL = "en.wiktionary.org"
CATEGORIES = ["_surnames", "_male_given_names", "_female_given_names"]
LANGUAGES = {
        "sq": "Albanian",
        "nl": "Dutch",
        "en": "English",
        "fr": "French",
        "de": "German",
        "ga": "Irish",
        "it": "Italian",
        "pt": "Portuguese",
        "es": "Spanish",
        "tr": "Turkish",
        "ro": "Romanian",
}


def get_pages(category):
    pages = []
    category = "Category:" + category
    params = {
        "action": "query",
        "list": "categorymembers",
        "cmtitle": category,
        "cmlimit": "max",
        "format": "json"
    }

    while True:
        query_string = urllib.parse.urlencode(params)
        full_url = f"https://{API_URL}/w/api.php?{query_string}"
        print("Requesting URL:", full_url)

        # save url in pages
        if len(pages) == 0:
            pages.append("# " + full_url)
        
        conn = http.client.HTTPSConnection(API_URL)
        conn.request("GET", "/w/api.php?" + query_string)
        response = conn.getresponse()
        data = response.read().decode("utf-8")
        conn.close()

        json_data = json.loads(data)
        members = json_data.get("query", {}).get("categorymembers", [])

        # Keep only entries with ns=0, so only main categories
        pages.extend(m["title"] for m in members if m["ns"] == 0)

        if "continue" in json_data:
            params["cmcontinue"] = json_data["continue"]["cmcontinue"]
        else:
            break

    return pages


def array_to_file(array, file_name):
    with open(file_name, 'w') as f:
        for element in array:
            f.write(f"{element}\n")


print("getting names...")
for code, language in LANGUAGES.items():
    for category in CATEGORIES:
        # get data
        full_category = language + category
        print("getting " + full_category)
        names = get_pages(full_category)
        
        # write data to file
        file_name = code + category + ".csv"
        file_name = file_name.replace("_given", "")
        print("writing to file " + file_name)
        array_to_file(names, file_name)

print("getting names done.")
