here is new script

folder="."
lines=0

# check if the folder is provided
if  [ $# -ge 1 ]; then
    folder="$1"
fi

# check if number of lines is provided
if [ $# -ge 2 ]; then
    lines="$2"
fi

echo "Searching for fasta/fa files in Folder: $folder"
echo "Number of lines: $lines"

# locate the files with .fasta or .fa extensions
 find "$folder" -type f -name "*.fasta" -o -name "*.fa" | while read -r file; do
    echo "Processing file: $file"

    #check if the file is a symlink
    if [ -h "$file" ]; then
        echo "File is a symlink."
    else
        echo "File is not a symlink."
    fi

    # count the number of sequences in the file
    sequence_count=$(grep -c "^>" "$file")
    
    echo "Number of sequences in $file: $sequence_count"

    # calculate the total sequence length
    total_length=$(grep -v "^>" "$file" | sed 's/[[:space:]]//g' | wc -c)
    echo "Total sequence length in $file: $total_length"

    # select lines start with '>' - those are typical for fasta headers; remove this sign '>'; extract the first word from fasta headers
    fasta_ids=$(grep "^>" "$file" | sed 's/>//g' | cut -d' ' -f1)

    # translates spaces to newlines, creating fasta IDs into a list; sorts the list and keeps only unique fasta IDs
    echo "Unique Fasta IDs:"
    echo "$fasta_ids" | sed 's/ /\n/g' | sort -u
    
    # counts the number of lines, which corresponds to the number of unique fasta IDs
    unique_count=$(echo "$fasta_ids" | sed 's/ /\n/g' | sort -u | wc -l)
    
    echo "Total number of unique Fasta IDs: $unique_count"
done


