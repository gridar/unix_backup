datetime=$(date +%s)
host=$(hostname)
backup_name="backup_"$datetime"_"$host.tar.gz
backup_init="backup_init.tar.gz"


function store() {
    local files_list=$@
    #pushd $src_directory
    back_dir=$src_directory"/.backup/"

    #creation of .backup if doesn't exist
    if ! [ -d $back_dir ];then
      mkdir $src_directory"/.backup/"
    fi

    if ! [ -f $back_dir$backup_init ]; then
      if ! [ -z $files_list ]; then
        tar --append -C $src_directory --file=$back_dir$backup_init $files_list
        #tar -czf .backup/$backup_init.gz $files_list
      fi
    else
      local txt_files=$(file -0 $files_list | sed -n '/text/p' | awk '{print $1}')
      local bin_files=$(file -0 $files_list | sed '/text/d' | awk '{print $1}')

      for file in $files_list; do
        if [ -z $(file -0 $src_directory"/"$file | sed -n '/text/p') ]; then
            echo tar bin
            echo $file
            echo -----
           tar --append -C $src_directory --file=$back_dir$backup_name $file
        else
          local is_file_exist=$(tar -tf $back_dir$backup_init $file)
          echo existing file:
          echo $is_file_exist
          echo -------
          if [ -z $is_file_exist ]; then
            echo new file:
            echo $file
            echo -----
            tar --append -C $src_directory --file=$back_dir$backup_init $file
            touch $back_dir"/"$file
            tar --append -C $back_dir --file=$back_dir$backup_name $file
            rm $back_dir"/"$file
          else
            echo "check diff"
            #check diff
          fi
        fi

      done


      # tar --append -C $src_directory --file=$back_dir$backup_name /dev/null
      #
      # # Archive binary files in new backup if any
      # if ! [ -z $bin_files ]; then
      #   echo Archiving bin files $bin_files
      #   tar --append -C $src_directory --file=$back_dir$backup_name $bin_files
      # fi
      #
      # # Unzip tar files
      #
      # gunzip .backup/$backup_init
      # gunzip .backup/$backup_name
      #
      # # Archive text files
      # for txt in $txt_files; do
      #
      #   local is_file_exist=$(tar -tf .backup/$backup_init | grep $txt)
      #   echo $is_file_exist
        # if [ -z $is_file_exist ]; then
        #
        #   # Add file in backup_init then add empty file in current backup
        #   tar -rf .backup/$backup_init $txt
        #   touch .backup/$txt
        #   tar -rf .backup/$backup_name .backup/$txt
        #   rm .backup/$txt
        #
        # else
        #   echo "check diff"
        #   #check diff
        # fi
      # done
      #
      # gzip .backup/$backup_init
      # gzip .backup/$backup_name
      #check diff of text file if exist in init backup push diff in new backup if not push text in init and empty file in new backup
    fi

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
