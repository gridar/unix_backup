backup_init="backup_init.tar.gz"

function restore()
{
  local output_dir=$2

  local back_dir=$(dirname $1)

  local path_archive_file=$1
  local path_init_file=$back_dir"/"$backup_init

  echo output_dir
  echo $output_dir
  echo ---------

  echo back_dir
  echo $back_dir
  echo ---------



  if [[ ! -d $output_dir"/.restore" ]]; then
    mkdir $output_dir"/.restore"
  fi
  tar -C $output_dir"/.restore"  -zxvf $path_archive_file

  if [[ ! $path_archive_file -eq $path_init_file  ]]; then
    if [[ ! -d $output_dir"/.init" ]]; then
      mkdir $output_dir"/.init"
    fi
    tar -C $output_init"/.init" -zxvf $path_init_file
  fi


  # $files=$(find $output_dir"/.restore" -type f -maxdepth 1  -print | sed 's/.*\///g')
  #
  # for file in $files;do
  #   if [[ -z $(file -0 $output_dir"/.restore/"$file | sed -n '/text/p') ]]; then
  #     #binary file
  #     mv $output_dir"/.restore/"$file $output_dir"/"$file
  #   else
  #     #text file we have to patch
  #   fi
  #
  # done

}

restore $1 $2
