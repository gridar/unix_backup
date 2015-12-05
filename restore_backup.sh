#!/bin/bash
backup_init="backup_init.tar.gz"

function restore()
{
  local output_dir=$2
  local back_dir=$(dirname $1)

  local path_archive_file=$1
  local path_init_file=$back_dir"/"$backup_init


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

  if [[  $path_archive_file != $path_init_file ]]; then #if backup != init_backup

    if [[ ! -d $output_dir"/.init" ]]; then
      mkdir $output_dir"/.init"
    fi

    tar -C $output_dir"/.init" -zxvf $path_init_file

    for file in $files;do
      if [[ -z $(file -0 $output_dir"/restore/"$file | sed -n '/text/p') ]]; then
        #binary file
        mv $output_dir"/restore/"$file $output_dir"/"$file
      else

        if [[ -f $output_dir"/.init/"$file ]]; then
          local patch_file=$(echo $file | cut -d . -f1)
          mv $output_dir"/restore/"$file $output_dir"/"$patch_file.patch
          echo -------
          cat $output_dir"/"$patch_file.patch
          echo -------
          mv $output_dir"/.init/"$file $output_dir"/"$file
          patch < $output_dir"/"$patch_file.patch
        fi

        #text file we have to patch
      fi

    done
  else
    for file in $files; do
      mv $output_dir"/restore/"$file $output_dir"/"$file
    done
  fi




}

restore $1 $2
