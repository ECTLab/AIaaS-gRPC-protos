#!/bin/bash

OUTPUT_FOLDER="$1"

SUBFOLDERS=$(find "$OUTPUT_FOLDER" -type d)

for SUBFOLDER in $SUBFOLDERS; do
    touch "$SUBFOLDER/__init__.py"
done

touch "$OUTPUT_FOLDER/__init__.py"
