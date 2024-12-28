#!/bin/bash

# Check if directory path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/directory"
  exit 1
fi

# Get the directory from the command-line argument
directory="$1"

# Check if the provided directory exists
if [ ! -d "$directory" ]; then
  echo "Directory $directory does not exist."
  exit 1
fi

# Calculate the total size of the directory and all subdirectories in kilobytes
total_size_kb=$(du -sk "$directory" | awk '{print $1}')

# Convert the size from kilobytes to gigabytes
total_size_gb=$(echo "scale=2; $total_size_kb / 1024 / 1024" | bc)

# Linux: Find files, extract sizes and modification years, and sum by year
# find "$directory" -type f -exec stat --format='%y %s' {} + | \
# awk '{
#     split($1, date, "-")
#     year = date[1]

#     # Convert file size from bytes to GB
#     size = $4 / (1024*1024*1024)

#     # Accumulate the size per year
#     sizes[year] += size
# }
# END {
#     for (year in sizes)
#         printf "%s %.2f\n", year, sizes[year]
# } ' | sort

# MacOS: Find files, extract sizes and modification years, and sum by year
find "$directory" -type f -exec stat -f '%Sm %z' {} + | \
awk '{ 
    # Extract the year (last part of the modification timestamp)
    split($1, date, " "); 

    # Convert file size from bytes to GB
    size = $5 / (1024*1024*1024);

    # Accumulate the size per year
    sizes[$4] += size
}
END {
    # Print year and its accumulated size in GB with 2 decimal places
    for (year in sizes)
        printf "%s %.2f\n", year, sizes[year]
} ' | sort

# Output the total size in GB at the end
echo "Total size of '$directory' and its subdirectories is: $total_size_gb GB"
