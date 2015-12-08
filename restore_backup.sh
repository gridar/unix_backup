#!/bin/bash
BACKUP_INIT_FILE_NAME="backup_init.tar.gz"

function restore()
{
  local output_dir=${2-./}
  local back_dir=$(dirname ${1-./})
  local path_archive_file=$1
  local path_init_file=$back_dir"/"$BACKUP_INIT_FILE_NAME

  if [[ ! -f $path_archive_file ]]; then
    echo "Archive file doesn't exist"
    exit 0
  fi

  if [[ ! -d $output_dir ]]; then
    echo "Output directory doesn't exist"
    exit 0
  fi

  if [[ ! -d $output_dir"/restore" ]]; then
    mkdir $output_dir"/restore"
  fi

  # Un archive all initial files
  tar -C $output_dir"/restore"  -zxvf $path_init_file
  # Un archive all patches and binaries
  tar -C $output_dir"/restore"  -zxvf $path_archive_file

  local files=$(find $output_dir"/restore" -type f -maxdepth 1 -print | sed 's/.*\///g')

  for file in $files; do #for all files
    # if it's a text file
    if [[ ! -z $(file -0 $output_dir"/restore/"$file | sed -n '/text/p') ]]; then
      patch_datas=$(grep '^--- ' $output_dir"/restore/"$file)
      #if it's a patch file
      if [[ ! -z $patch_datas ]]; then
        # Then find the init file and patch it
        local patch_file=$file
        tar -zxvf $path_init_file $file
        patch -t --no-backup-if-mismatch $file $output_dir"/restore/"$file
        # remove patch file
        rm $output_dir"/restore/"$file
        # add patched file to restore directory
        mv $file $output_dir"/restore"
      fi
    fi
  done  

}

restore $1 $2
