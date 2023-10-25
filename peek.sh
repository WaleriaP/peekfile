#!/bin/bash

# Check if an input file is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

# Get the input file from the command line argument
input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file"
  exit 1
fi

# Use the 'head' and 'tail' commands to extract the first and last three lines
head -n 3 "$input_file"
echo "..."
tail -n 3 "$input_file"
