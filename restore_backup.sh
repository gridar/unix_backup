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
  local init_tar=$(echo $BACKUP_INIT_FILE_NAME | cut -d . -f 1)
  cp $path_init_file $back_dir"/"$init_tar".tar"
	tar -C $output_dir"/restore" -xvf $back_dir"/"$init_tar".tar"
	rm $back_dir"/"$init_tar".tar"  

  # Un archive all patches and binaries

	local back_tar=$(basename $path_archive_file | cut -d . -f 1)
  cp $path_archive_file $back_dir"/"$back_tar".tar"
	tar -C $output_dir"/restore" -xvf $back_dir"/"$back_tar".tar"
	rm $back_dir"/"$back_tar".tar" 


  local files=$(find $output_dir"/restore" -maxdepth 1 -type f -print | sed 's/.*\///g')

  for file in $files; do #for all files
    # if it's a text file
    if [[ ! -z $(file -0 $output_dir"/restore/"$file | sed -n '/text/p') ]]; then
      patch_datas=$(grep '^--- ' $output_dir"/restore/"$file)
      #if it's a patch file
      if [[ ! -z $patch_datas ]]; then
        # Then find the init file and patch it
        local patch_file=$file
				local back_init_tar=$(echo $BACKUP_INIT_FILE_NAME | cut -d . -f 1)
  			cp $path_init_file $back_dir"/"$back_init_tar".tar"
				tar -xvf $back_dir"/"$back_init_tar".tar" $file
				rm $back_dir"/"$back_init_tar".tar"

        patch -t --no-backup-if-mismatch $file $output_dir"/restore/"$file
        # remove patch file
        rm $output_dir"/restore/"$file
        # add patched file to restore directory
        mv $file $output_dir"/restore"
      fi			
    fi
		
		local file_size=$(stat -c%s $output_dir"/restore/"$file)

    if [[ $file_size -eq 0 ]]; then
			local back_init_tar=$(echo $BACKUP_INIT_FILE_NAME | cut -d . -f 1)
			cp $path_init_file $back_dir"/"$back_init_tar".tar"
			tar -xvf $back_dir"/"$back_init_tar".tar" $file
			rm $back_dir"/"$back_init_tar".tar"
			# remove patch file
      rm $output_dir"/restore/"$file
      # add patched file to restore directory
      mv $file $output_dir"/restore"
    fi
		

  done  

}

restore $1 $2
