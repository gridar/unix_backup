function store() {
    files_list=$@
    echo $files_list
    echo $src_directory
    mkdir "$src_directory"/.backup
    #rm "$src_directory"/.backup/backup.tar.gz
    tar -czf "$src_directory"/.backup/backup.tar.gz "$files_list"
}

function backup() {
  local src_directory="$1"

  local directories=$(ls -l $src_directory | grep "^d" | awk '{print $9}')

  echo in $src_directory

  # skip comments and blank lines
  find_arg=" -type f"
  read -ra words <<< $(sed -e 's/#.*// ; /^[[:space:]]*$/d' "$backignore")
  for word in ${words[@]}; do
    find_arg+=" ! -name $word"
  done

  find_arg+=" -maxdepth 1 -print "
  files=$(find $src_directory $find_arg)
   
  store $files
  echo ""

  for directory in $directories; do
    backup "$src_directory/$directory" "$backignore"
  done



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
