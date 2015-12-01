function store() {
    files_list="$(find $@)"
    echo $files_list
    tar -czf backup.tar.gz $files_list
}

function backup() {
  local src_directory="$1"
  local backignore="$2"

  local directories=$(ls -l $src_directory | grep "^d" | awk '{print $9}')
  echo directories:
  echo $directories
  
  local files=$(ls -l $src_directory | grep "^-" | awk '{print $9}')
  echo files:
  echo $files


  # files=grep raw_list
  # mkdir .backup

    echo i am in $src_directory
  for directory in $directories; do
    echo ,    go to
    echo $src_directory/$directory
    backup "$src_directory/$directory" "$backignore"
  done

  #store files


  # # skip comments and blank lines
  # read -ra words <<< $(sed -e 's/#.*// ; /^[[:space:]]*$/d' "$backignore")
  # for word in ${words[@]}; do
  #   find_arg+=" ! -name "$word
  # done
  # find_arg+=" -print"

  #store "$directory" $find_arg
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

backup "$directory" "$backignore"
