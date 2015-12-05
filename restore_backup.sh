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

  
  tar -C $output_dir"/restore"  -zxvf $path_archive_file

  local files=$(find $output_dir"/restore" -type f -maxdepth 1 -print | sed 's/.*\///g')
  
  echo files
  echo $files


#to do for each files 
  local file="file3.txt"
  if [[ -z $(file -0 $output_dir"/restore/"$file | sed -n '/text/p') ]]; then
    #if it is not a bin file
    echo whouhouhouh
  fi

  patch_datas=$(grep '^--- ' $output_dir"/restore/"$file)
  
  if [[ ! -z $patch_datas ]]; then
    echo find a patch file
    local patch_file=$file

    #unzip initial file in BACKUP_INIT_FILE_NAME
    #make patch
    #delete patch file
    #done
  fi
  

}

restore $1 $2
