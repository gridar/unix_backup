removebackup=$(find example_files/ -name .backup -print)

for i in $removebackup; do
  rm -rf $i
done
