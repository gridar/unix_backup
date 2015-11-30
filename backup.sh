function store() {
    printf '%q\n' "$@"
    echo find "$@"
    find $@
}

function backup() {
  directory="$1"
  backignore="$2"

  # skip comments and blank lines
  read -ra words <<< $(sed -e 's/#.*// ; /^[[:space:]]*$/d' "$backignore")
  for word in ${words[@]}; do
    find_arg+=" ! -name ""$word"
  done
  find_arg+=" -print"
  store "$directory" $find_arg
}

usage() {
    echo "$(basename $0) [ -d directory ] [ -i ignorefile ]"
    exit 1
}

directory=''
backignore='.ignorefile'    # default

while getopts "i:d:h" opt ; do
  case "$opt" in
    d)  directory="$OPTARG" ;;
    i)  backignore="$OPTARG" ;;
    *) usage ;;
  esac
done

[ -z "$directory" ] && echo "Please provide a directory." && usage

backup "$directory" "$backignore"
