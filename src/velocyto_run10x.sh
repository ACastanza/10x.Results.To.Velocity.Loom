#! /bin/bash
# Using getopt
set -e

trap abort ERR PROF
abort()
{
rm -rf chromium

    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
}

while getopts ":c:g:s:m:j:" opt; do
    case $opt in
        c)
            chromium=`realpath $OPTARG`
            ;;
        g)
            gtf=`realpath $OPTARG`
            ;;
        s)
          if [[ $OPTARG =~ ^[^-]+$ ]];then
            metadata=`realpath $OPTARG`
            echo "-s <sample metadata table> = $metadata"
          elif [[ $OPTARG =~ ^-. ]];then
            metadata=""
            let OPTIND=$OPTIND-1
          else
            metadata=`realpath $OPTARG`
            echo "-m <metadata table> = $metadata"
          fi          
            ;;
        m)
          if [[ $OPTARG =~ ^[^-]+$ ]];then
            mask=`realpath $OPTARG`
            echo "-f <file containing intervals to mask> = $metadata"
          elif [[ $OPTARG =~ ^-. ]];then
            mask=""
            let OPTIND=$OPTIND-1
          else
            metadata=`realpath $OPTARG`
            echo "-f <file containing intervals to mask = $metadata"
          fi          
            ;;
        j)
            threads="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            abort
            ;;
    esac
done

chromium_name=$(basename -- "$chromium")
chromium_extension="${chromium_name##*.}"
if [[$gtf_extension == "gz"]]; then
 unzip_chromium="${chromium_name%.tar.gz}"
 mkdir -p chromium/$unzip_chromium
 tar -zxvf $chromium -C chromium/$unzip_chromium
elif [[$gtf_extension == "zip"]]; then
 unzip_chromium="${chromium_name%.zip}"
 mkdir -p chromium
 unzip $chromium -d chromium
 rm -rf chromium/__MACOSX
fi

gtf_name=$(basename -- "$gtf")
gtf_extension="${gtf_name##*.}"
if [[$gtf_extension == "gz"]]; then
 unzip_gtf="${gtf_name%.*}"
 gunzip -c $gtf > $unzip_gtf
 gtf=$unzip_gtf
fi

mask_name=$(basename -- "$mask")
mask_extension="${mask_name##*.}"
if [[$mask_extension == "gz"]]; then
 unzip_mask="${mask_name%.*}" 
 gunzip -c $mask > $unzip_mask
 mask=$unzip_mask
fi

params=()
[[ "$metadata" != "" ]] && params+=(--metadatatable $metadata)
[[ "$mask" != "" ]] && params+=(--mask $mask)

velocyto run10x \
      "${params[@]}" \
      chromium \
      $gtf \
      --dtype "uint32";

rm -rf chromium $(basename ${gtf/%.gz}) $(basename ${mask/%.gz})

    echo "Done." ;
 done
