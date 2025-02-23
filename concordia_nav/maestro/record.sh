#!/bin/bash

directory="maestro"
pattern="${1:-.*}"  # Default pattern is '.*' which matches all files

for file in "$directory"/*.yaml; 
do
    if [[ -f "$file" && "$(basename "$file")" != "config.yaml" && "$(basename "$file")" =~ ^${pattern} ]]; then
        filename=$(basename "$file" .yaml)
        maestro record "$file" --local "$directory/recordings/$filename.mp4"
    fi
done