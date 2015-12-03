datetime=$(data +%s)
host=$(hostname)
name_backup="backup_"$datetime_$host.tar.gz
backup_init="backup_init.tar.gz"


function check_diff() {

}

function store() {
    files_list=$@
    echo list file:
    echo $files_list
    echo $src_directory
    $(pushd $src_directory)

    #creation of .backup if doesn't exist
    if ! [ -d ".backup" ];then
      mkdir .backup
    fi

    if ! [ -f .backup/$backup_init]; then
      tar -czf .backup/$backup_init $files_list
    else
      txt_file=$(file -0 $files_list | sed -n '/text/p' | awk '{print $1}')
      bin_file=$(file -0 $files_list | sed '/text/d' | awk '{print $1}')

      #push binary file in new backup

      #check diff of text file if exist in init backup push diff in new backup if not push text in init and empty file in new backup


    fi

    #file -0 * | sed '/text/d' | awk '{print $1}'
    #if ! [ -f .backup/$name_backup.tar.gz ];then
    #  tar -czf .backup/$name_backup $files_list
    #else
    #  tar -rzf .backup/$name_backup.tar.gz $files_list
    #fi



    #rm "$src_directory"/.backup/backup.tar.gz

    $(popd)
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
  files=$(find $src_directory $find_arg | sed 's/.*\///g')

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
