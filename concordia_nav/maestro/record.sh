#!/bin/bash

directory="maestro"

for file in "$directory"/*.yaml; 
do
    if [[ -f "$file" && "$(basename "$file")" != "config.yaml" ]]; then
        filename=$(basename "$file" .yaml)
        maestro record "$file" --local "$directory/recordings/$filename.mp4"
    fi
done