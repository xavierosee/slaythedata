#! /bin/bash

hr_filesize() {
  local bytes=$1
  awk '
    function human(x) {
      if(x<1024) return x "B";
      else if (x<1048576) return sprintf("%.1fK", x/1024);
      else if (x<1073741824) return sprintf("%.1fM", x/1048576);
      else return sprintf("%.1fG", x/1073741824);
    }
    {print human($0)}
  ' <<< "$bytes"
}

usage() {
  echo "USAGE: $0 [OPTIONS] SRC DEST AMOUNT"
  echo "   SRC              Path to the folder containing the JSON files to copy"
  echo "   DEST             Path where to copy the data files"
  echo "   AMOUNT           Amount \(in GB\) to copy"
  echo "\nOPTIONS"
  echo "   -h, --help       Display this help message and exit."
  echo "   -v, --verbose    Enable verbosity."
}

verbose_output() {
  if [[ $verbose -eq 1 ]]; then
    echo "$1"
  fi
}

verbose=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -v|--verbose)
      verbose=1
      shift
      ;;
    *)

      if [[ ! -d "$1" ]]; then
        echo "ERROR: Source directory '$1' does not exist." 1>&2
        exit 1
      fi

      if [[ ! -d "$2" ]]; then
        echo "Destination directory '$2' does not exist."
        echo "Creating Destination directory '$2'..."
        if mkdir -p -m 755 "$2"; then
          echo "Destination directory '$2' successfully created."
        else
          echo "ERROR: Failed to create directory '$2'" 1>&2
          exit 1
        fi
      fi

      verbose_output "Argument 1: '$1'"
      verbose_output "Argument 2: '$2'"
      verbose_output "Argument 3: '$3'"

      if ! [[ "$3" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "ERROR: '$3' is not a valid number." 1>&2
        exit 1
      fi

      src_dir="$1"
      verbose_output "Source directory set to $src_dir"
      dest_dir="$2"
      verbose_output "Destination directory set to $dest_dir"
      amt_gb="$3"
      shift 3
      ;;
  esac
done

# Check disk space
avail_space_mb=$(df -P -m "$dest_dir" | awk 'NR==2 {print $4}')
limit_mb=$(echo "$amt_gb * 1024" | bc)
if (( avail_space_mb < limit_mb )); then
  echo "ERROR: Not enough space available in $dest_dir. Required: $limit_mb MB, Available: $avail_space_mb MB" 1>&2
  exit 1
fi


# convert GB to bytes
limit=$(echo "$amt_gb * 1024 * 1024 * 1024" | bc)
verbose_output "Maximum amount of data to copy set to $amt_gb G ($limit bytes)"

# running nb of bytes
copied_bytes=0
copied_files=0

# running through files in source directory

find "$src_dir" -maxdepth 1 -name '*.json' | sort | while IFS= read -r file; do
  # get the size of the file in bytes
  filesize=$(wc -c < "$file")

  # check if copying this file will exceed the limit
  if (( copied_bytes + filesize > limit )); then
    break
  fi

  # copy the file
  if ! cp "$file" "${dest_dir}/"; then
    echo "ERROR: Failed to copy $file to ${dest_dir}" 1>&2
    exit 1
  fi
  verbose_output "Copied $file to ${dest_dir}"
  copied_bytes=$((copied_bytes + filesize))
  copied_files=$((copied_files + 1))
done

echo "Successfully copied ${copied_files} files to ${dest_dir}. $(hr_filesize "$copied_bytes") copied."
