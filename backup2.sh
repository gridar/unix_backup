datetime=$(date +%s)
host=$(hostname)
backup_name="backup_"$datetime"_"$host.tar
backup_init="backup_init.tar"


function store() {
    local files_list=$@
    echo $src_directory
    pushd $src_directory

    #creation of .backup if doesn't exist
    if ! [ -d ".backup" ];then
      mkdir .backup
    fi

    if ! [ -f .backup/$backup_init.gz ]; then
      tar -czf .backup/$backup_init.gz $files_list
    else
      local txt_files=$(file -0 $files_list | sed -n '/text/p' | awk '{print $1}')
      local bin_files=$(file -0 $files_list | sed '/text/d' | awk '{print $1}')

      #push binary file in new backup
      if ! [ -f .backup/$backup_name.gz ]; then
        tar -czf .backup/$backup_name.gz $bin_files
      fi

      gunzip .backup/$backup_init.gz
      gunzip .backup/$backup_name.gz

      for txt in $txt_files; do
        local already_exist=$(tar -ztf .backup/$backup_init.gz | grep $txt)
        echo -----
        echo exist : $already_exist

        if [ -z $already_exist ]; then
          echo ----
          echo try to add: $txt
          echo ---
          tar -rf .backup/$backup_init $txt
          touch .backup/$txt
          tar -rf .backup/$backup_name .backup/$txt
          rm .backup/$txt
        else
          echo "check diff"
          #check diff
        fi
      done
      gzip .backup/$backup_init
      #check diff of text file if exist in init backup push diff in new backup if not push text in init and empty file in new backup
    fi
    popd
}


function backup() {
  local src_directory="$1"

  local directories=$(ls -l $src_directory | grep "^d" | awk '{print $9}')

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
