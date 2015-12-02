function store() {
    files_list="$(find $@)"
    echo $files_list
    tar -czf backup.tar.gz $files_list
}

function backup() {
  local src_directory="$1"

  echo i am in $src_directory
  echo ${ignore[@]}

  local directories=$(ls -l $src_directory | grep "^d" | awk '{print $9}')
  
  local files=$(ls -l $src_directory | grep "^-" | awk '{print $9}')
  echo files:
  echo $files

  # files=grep raw_list
  # mkdir .backup

  for directory in $directories; do
    backup "$src_directory/$directory" "$backignore"
  done

  #store files


  # # skip comments and blank lines
  # read -ra words <<< $(sed -e 's/#.*// ; /^[[:space:]]*$/d' "$backignore")
  # for word in ${words[@]}; do
  #   find_arg+=" ! -name "$word
  # done
}

function usage() {
    echo "$(basename $0) [ -d directory ] [ -i backignore ]"
    exit 1
}


######## MAIN #######

directory=''
backignore='.backignore'    # default
while getopts "i:d:h" opt ; do
  case "$opt" in
    d)  directory="$OPTARG" ;;
    i)  backignore="$OPTARG" ;;
    *) usage ;;
  esac
done

[ -z "$directory" ] && echo "Please provide a directory." && usage

ignore=$(sed -e 's/#.*// ; /^[[:space:]]*$/d' "$backignore")
backup "$directory"
