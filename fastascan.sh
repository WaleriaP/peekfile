here is new script

folder="."
lines=0

if  [ $# -ge 1 ]; then
    folder="$1"
fi

if [ $# -ge 2 ]; then
    lines="$2"
fi

echo "Searching for fasta/fa files in Folder: $folder"
echo "Number of lines: $lines"

find "$folder" -type f -name "*.fasta" -o -name "*.fa" | while read -r file; do
    echo "Found: $file"
     
done



