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

  tar -C $output_dir"/restore"  -zxvf $path_init_file
  tar -C $output_dir"/restore"  -zxvf $path_archive_file

  local files=$(find $output_dir"/restore" -type f -maxdepth 1 -print | sed 's/.*\///g')
  
  echo files
  echo $files

  for file in $files; do
    if [[ ! -z $(file -0 $output_dir"/restore/"$file | sed -n '/text/p') ]]; then
      patch_datas=$(grep '^--- ' $output_dir"/restore/"$file)
      
      if [[ ! -z $patch_datas ]]; then
        echo find a patch file
        local patch_file=$file
        tar -zxvf $BACKUP_INIT_FILE_NAME $file
        patch -t --no-backup-if-mismatch $file ./restore/$file
        rm ./restore/$file
        mv $file ./restore
      fi
    fi
  done  

}

restore $1 $2
