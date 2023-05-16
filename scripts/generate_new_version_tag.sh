#!/bin/bash

TAGS=$(git tag --sort=-version:refname --merged master --list 'v[0-9]*.[0-9]*.[0-9]*')

LAST_TAG=$(echo "$TAGS" | head -n1)

LAST_DIGIT=$(echo "$LAST_TAG" | awk -F '.' '{print $3}')
NEXT_DIGIT=$((LAST_DIGIT + 1))

NEW_TAG=$(echo "$LAST_TAG" | sed "s/\.[0-9]*$/.$NEXT_DIGIT/")

git checkout master
git tag "$NEW_TAG"
git push origin "$NEW_TAG"
