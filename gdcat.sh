#!/usr/bin/env bash
# Usage (MacOS): ./gdcat.sh /path/to/godot/project | pbcopy

# root directory to scan (defaults to current dir if not passed)
ROOT="${1:-.}"

# walk recursively, find *.gd, sort for stable order
find "$ROOT" -type f -name '*.gd' | sort | while read -r file; do
  # compute relative path
  rel="${file#$ROOT/}"

  echo "## $rel"
  echo
  echo '```gdscript'
  cat "$file"
  echo '```'
  echo
done