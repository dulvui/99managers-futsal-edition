#!/bin/bash

# Check if the input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input.csv"
    exit 1
fi

# Read the CSV file and convert it to gettext format
while IFS=',' read -r key value; do
    # Skip the header line
    if [[ "$key" != "key" ]]; then
        echo "msgid $key"
        echo "msgstr $value"
        echo ""
    fi
done < "$1"
