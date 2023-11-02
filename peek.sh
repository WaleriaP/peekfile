#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <input_file> [number_of_lines]"
    exit 1
fi

LINES=${2:-3}

if [ ! -f "$1" ]; then
    echo "Error: Input file '$1' not found."
    exit 1
fi

TOTAL_LINES=$(wc -l < "$1")

if [ "$TOTAL_LINES" -le $((2 * LINES)) ]; then
    cat "$1"
else
   
    head -n "$LINES" "$1"
    echo "..."
    tail -n "$LINES" "$1"
fi
