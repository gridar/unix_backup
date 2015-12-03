datetime=$(date +%s)
host=$(hostname)
backup_name="backup_"$datetime"_"$host.tar
backup_init="backup_init.tar"


function store() {
    local files_list=$@
    pushd $src_directory

    #creation of .backup if doesn't exist
    if ! [ -d ".backup" ];then
      mkdir .backup
    fi

    if ! [ -f .backup/$backup_init.gz ]; then
      
      if ! [ -z $files_list ]; then
        tar -czf .backup/$backup_init.gz $files_list
      fi
    
    else
      local txt_files=$(file -0 $files_list | sed -n '/text/p' | awk '{print $1}')
      local bin_files=$(file -0 $files_list | sed '/text/d' | awk '{print $1}')

      tar -czf backup_name.gz /dev/null
      # Archive binary files in new backup if any
      if ! [ -z $bin_files ]; then
        echo Archiving bin files $bin_files
        tar -czf .backup/$backup_name.gz $bin_files
      fi

      # Unzip tar files

      gunzip .backup/$backup_init.gz
      gunzip .backup/$backup_name.gz

      # Archive text files
      for txt in $txt_files; do
        
        local is_file_exist=$(tar -tf .backup/$backup_init | grep $txt)
        echo $is_file_exist
        if [ -z $is_file_exist ]; then

          # Add file in backup_init then add empty file in current backup
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
      gzip .backup/$backup_name
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
