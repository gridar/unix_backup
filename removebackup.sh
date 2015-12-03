removebackup=$(find example_files/ -name .backup)

for i in $removebackup; do
  rm -rf $i
done
