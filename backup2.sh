datetime=$(date +%s)
host=$(hostname)
backup_name="backup_"$datetime"_"$host.tar.gz
backup_init="backup_init.tar.gz"


function store() {
    local files_list=$@
    #pushd $src_directory
    back_dir=$src_directory"/.backup/"

    #creation of .backup if doesn't exist
    if [[ ! -d $back_dir ]];then
      mkdir $src_directory"/.backup/"
    fi

    if [[ ! -f $back_dir$backup_init ]]; then #if backup_init doesn't exist
      if [[ ! -z $files_list ]]; then
        tar --append -C $src_directory --file=$back_dir$backup_init $files_list #we create backup_init.tar.gz
      fi
    else
      for file in $files_list; do
        if [[ -z $(file -0 $src_directory"/"$file | sed -n '/text/p') ]]; then #We check if the file is not a text file
           #if it is a bin file
           tar --append -C $src_directory --file=$back_dir$backup_name $file
        else
          #if it is a text file

          local is_file_exist=$(tar -tf $back_dir$backup_init $file) #Get specific file of tar.gz
          if [[ -z $is_file_exist ]]; then
            #file not present in backup_init
            #we add it to backup_init
            tar --append -C $src_directory --file=$back_dir$backup_init $file
            touch $back_dir$file
            tar --append -C $back_dir --file=$back_dir$backup_name $file
            rm $back_dir$file
          else
            #make a diff and store in in new backup
	    local tar_file=$(echo $backup_init | cut -d . -f 1)
	    cp $back_dir$backup_init $backdir$tar_file".tar"
            tar -C $back_dir -xvf $backdir$tar_file".tar" $file
	    rm $backdir$tar_file".tar"
            local diff_file=$(diff -u $src_directory"/"$file $back_dir$file)
            if [[ ! -z $diff_file ]]; then
              touch $back_dir$file".patch" #creation of patch file
              diff -u $src_directory"/"$file $back_dir$file > $back_dir$file".patch"
              rm $back_dir$file
              mv $back_dir$file".patch" $back_dir$file
              tar --append -C $back_dir --file=$back_dir$backup_name $file
            fi
            rm $back_dir$file
          fi
        fi
      done
    fi
}


function backup() {
  local src_directory="$1"

  local directories=$(ls -l $src_directory | grep "^d" | awk '{print $9}')

  # skip comments and blank lines
  find_arg=" -maxdepth 1 -type f "
  read -ra words <<< $(sed -e 's/#.*// ; /^[[:space:]]*$/d' "$backignore")
  for word in ${words[@]}; do
    find_arg+=" ! -name $word"
  done

  find_arg+=" -print "
  files=$(find $src_directory $find_arg | sed 's/.*\///g')

  store $files

  for directory in $directories; do
    backup "$src_directory/$directory" "$backignore"
  done
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
