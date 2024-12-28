#!/bin/bash

# Path to the directory where the files are located
upload_dir="/var/www/<project_dir>/storage"

# Path to the comma-separated file containing filenames
file_list="filesToPrune.txt"

# Read the comma-separated list of filenames into an array
IFS=',' read -r -a filenames < "$file_list"

# Batch size for deleting files
batch_size=999

# Temporary array to store filenames for batch deletion
batch=()

# Function to remove a file from the file list and clean up commas
remove_file_from_list() {
  local filename="$1"
  # Remove the exact filename with its comma, handling beginning, middle, and end of the list
  sed -i "s/\(^\|,\)$filename\($\|,\)//g" "$file_list"
}

# Function to delete a file and remove it from the list if it exists
delete_file() {
  local filename="$1"
  local file_path="$upload_dir/$filename"
  
  if [[ -f "$file_path" ]]; then
    echo "Deleting: $file_path"
    rm "$file_path" && remove_file_from_list "$filename"
  else
    remove_file_from_list "$filename"
    echo "File not found: $file_path"
  fi
}

# Function to process a batch of files for deletion
process_batch() {
  for filename in "${batch[@]}"; do
    delete_file "$filename"
  done
  # Reset the batch array after processing
  batch=()
}

# Loop through the filenames and delete the matching files in batches
for filename in "${filenames[@]}"; do
  # Add the filename to the batch array
  batch+=("$filename")

  # If the batch size is reached, process the batch and then stop
  if [ ${#batch[@]} -ge $batch_size ]; then
    process_batch
    break  # Stop the script after processing the first batch
  fi
done

echo "Batch deletion completed."