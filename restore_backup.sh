backup_init="backup_init.tar.gz"

function restore()
{
  local output_dir=$2

  local back_dir=$(direname $1)

  local path_archive_file=$1
  local path_init_file=$back_dir"/"$backup_init

  if [[ ! -d $output_dir"/.restore" ]]; then
    mkdir $output_dir"/.restore"
  fi

  if [[ ! -d $output_dir"/.init" ]]; then
    mkdir $output_dir"/.init"
  fi

  tar -C $output_dir"/.restore"  -zxvf $path_archive_file
  tar -C $output_init"/.init" -zxvf $path_init_file

  $files=$(find $output_dir"/.restore" -type f -maxdepth 1  -print | sed 's/.*\///g')

  for file in $files;do
    if [[ -z $(file -0 $output_dir"/.restore/"$file | sed -n '/text/p') ]]; then
      #binary file
      mv $output_dir"/.restore/"$file $output_dir"/"$file
    else
      #text file we have to patch
    fi

  done

}
