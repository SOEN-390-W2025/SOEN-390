#!/bin/bash

directory="maestro"

for file in "$directory"/*.yaml; 
do
    # Check if the file exists
    if [[ -f "$file" ]]; then
        filename=$(basename "$file" .yaml)
        maestro record "$file" --local "$directory/recordings/$filename.mp4"
    fi
done