removebackup=$(find example_files/ -name .backup -name .result -name .init)

for i in $removebackup; do
  rm -rf $i
done
