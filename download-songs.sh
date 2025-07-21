helpFunction()
{
   echo ""
   echo "Usage: $0 -u urls -o outpath"
   echo -e "\t-u urls"
   echo -e "\t-o outpath"
   exit 1 # Exit script after printing help
}

if ! command -v yt-dlp &> /dev/null
then
    echo "yt-dlp is not installed"
    exit
fi

while getopts "u:o:" opt
do
   case "$opt" in
      u ) urls="$OPTARG" ;;
      o ) outpath="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$urls" ] || [ -z "$outpath" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
mkdir -p $outpath

yt-dlp -f m4a -o "$outpath/%(artist)s - %(track)s.%(ext)s" --embed-metadata $urls
