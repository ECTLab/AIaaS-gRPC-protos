#!/bin/bash

git checkout master
git fetch --tags

TAGS=$(git tag --sort=-version:refname --list 'v[0-9]*.[0-9]*.[0-9]*')
echo "Tags: $TAGS"
if [ -z "$TAGS" ]; then
    echo "No tags found"
    exit 1
fi

LAST_TAG=$(echo "$TAGS" | head -n1)

LAST_DIGIT=$(echo "$LAST_TAG" | awk -F '.' '{print $3}')
NEXT_DIGIT=$((LAST_DIGIT + 1))

NEW_TAG=$(echo "$LAST_TAG" | sed "s/\.[0-9]*$/.$NEXT_DIGIT/")
echo "New tag: $NEW_TAG"

git tag "$NEW_TAG"
git push origin "$NEW_TAG"
