# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to > 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -i)
    FILE="$2"
    shift # past argument
    ;;
    -d)
    DIRECTORY="$2"
    shift # past argument
    ;;
    *)
      echo unknown option
    ;;
esac
shift # past argument or value
done
echo FILE = "${FILE}"
echo DIRECTORY = "${DIRECTORY}"
