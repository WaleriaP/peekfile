 !/bin/bash

usage() { echo "fastascan.sh [-X foldername] [-N numberoflines]" ; exit 1 ; }

# default values for optional arguments
folder="."
lines=0

# https://kodekloud.com/blog/bash-getopts/#:~:text=into%20the%20picture.-,What%20is%20getopts%3F,actions%20the%20script%20should%20take.
# using getopts to parse options -X -N if they exist, otherwise print an error message
while getopts ":X:N:" o; do
    case "${o}" in
        X)
            folder=${OPTARG}

            # short-circuit evaluation: if NOT directory (false || usage) => calls usage        
            # if IS directory (true || usage) => does not evaluate usage
            [ -d $folder ] || usage
            ;;
        N)
            lines=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

# in order to create an integer variable we use the declare command
# https://bash.cyberciti.biz/guide/Create_an_integer_variable
declare -i total_unique_fasta_ids=0
declare -i total_files=0

echo "Searching for fasta/fa files in Folder: $folder"
echo "Number of lines: $lines"

# https://stackoverflow.com/questions/38107413/variable-incremented-in-bash-while-loop-resets-to-0-when-loop-finishes
# reading from a redirected process output (see the done part of the loop)

while read -r file; do
    echo "Processing file: $file"

    # check if the file is a symlink
    if [ -h "$file" ]; then
        echo "File is a symlink."
        is_symlink="SYMLINK"
    else
        echo "File is not a symlink."
        is_symlink="NOSYMLINK"
    fi

    
    # count the number of sequences in the file
    sequence_count=$(grep -c "^>" "$file")    
    echo "Number of sequences in $file: $sequence_count"
    
    # calculate the total sequence length
    total_length=$(grep -v "^>" "$file" | sed 's/[[:space:]-]//g' | wc -c)
    echo "Total sequence length in $file: $total_length"

    # check whether it is a nucleotide

    # remove: all the header lines (inversed grep), all ACGTU characters & spaces
    # if there is something except newline characters in the result => it's an aminoacid
    # we had to trim all double spaces from the wc output to parse character number and line number from it
    non_acgtu=$(grep -v "^>" "$file" \
    	| sed 's/[[:space:]ACGTU-]//g' | wc \
    	| sed 's/  */ /g' | sed 's/^ *//g' | cut -d\  -f1,3)
    x=$(echo $non_acgtu | cut -d\  -f1)
    y=$(echo $non_acgtu | cut -d\  -f2)
    amino=$(( y - x ))
    if [[ $amino -gt 0 ]]
    then
    	total_a_files=$(( total_a_files + 1 ))
    	# echo "Aminoacid"
    	is_amino=Aminoacid
    else
    	total_n_files=$(( total_n_files + 1 ))
    	# echo "Nucleotide"
    	is_amino=Nucleotide
    fi 


    # select lines start with '>' 
    # - those are typical for fasta headers; 
    # remove this sign '>'; 
    # extract the first word from fasta headers
    fasta_ids=$(grep "^>" "$file" | sed 's/>//g' | cut -d' ' -f1)

    # translates spaces to newlines, creating fasta IDs into a list; sorts the list and keeps only unique fasta IDs
    #echo "Unique Fasta IDs:"
    unique_fasta_ids=$(echo "$fasta_ids" | sed 's/ /\n/g' | sort -u)

    # counts the number of lines, which corresponds to the number of unique fasta IDs
    unique_count=$(echo "$unique_fasta_ids" | wc -l)
    
    total_unique_fasta_ids=$(( total_unique_fasta_ids + unique_count ))
    # echo "Total number of unique Fasta IDs: $unique_count"

    total_files=$(( total_files + 1 ))

    echo "FILE($file) $is_symlink sequences=$sequence_count $is_amino"
     
    # short circuit: if lines equal 0 => True && continue and it continues
    # otherwise it's False && continue and continue is not evaluated
    [ $lines -eq 0 ] && continue

    # check if the file has more than 2N lines; -le stands for less than or equal to
    file_lines=$(wc -l < "$file")
    if [ $file_lines -le $((2 * $lines)) ]; then
        # displays full content
        cat "$file"
    else
        # displays the first N lines, then "...", then the last N lines
        head -n $lines "$file"
        echo "..."
        tail -n $lines "$file"
    fi

    echo

# locate the files with .fasta or .fa extensions
done < <(find -L "$folder" -type f -name "*.fasta" -o -name "*.fa")

# find output is redirected to the read in the begninning of the loop
# we use process substitution because we want the loop body
# to execute in the main process (not an a subprocess)
# if we wrote read after pipe:
# ... | read -r 
# it would run read and the whole loop body in a subprocess 
# and we wouldn't be able to access the total counters after the loop ended


echo "Total files: $total_files"
echo "Total number of unique Fasta IDs: $total_unique_fasta_ids"


