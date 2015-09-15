#! /bin/bash
# jf 9/14/15 script for importing geiger data in to elasticsearch
# */3 *    * * *   root    bash /home/jon/gmc_geiger_import.sh

# File is saved as $format.csv
directory="/home/jon/MOUNT/geiger"
files=$(ls $directory)
elasticsearch_ip=192.168.1.57
index_name=$(date +%F)
pull_time=$(date +%s)


for file in $files
do
# Gather data
data=$(grep '20[0-9][0-9]-[01]' $directory/$file)
timestamp_base=$(echo $data|awk -F, '{print $1}') #2015-09-13 20:06
timestamp=$(echo $timestamp_base|sed 's/ /T/')
cpm=$(echo $data|awk -F, '{print $3}')


# Process

# Send CPM
echo '{
"rad_count_cpm":'$cpm',
"@timestamp":"'$timestamp':00-0500"
}' > /home/jon/rad.cpm

curl --silent -XPOST "http://$elasticsearch_ip:9200/$index_name/Rad_Event/$pull_time" --data-binary @/home/jon/rad.cpm > /dev/null


# $4 to $64 are counts per second
second=4
tsec=0
while [[ $second -ne 64 ]]
do
rad_count=$(echo $data|awk -F, '{print $'$second'}')
if [[ $tsec -lt 10 ]]
then
usec=$(echo "0$tsec")
else
usec=$tsec
fi

echo '{
"rad_count":'$rad_count',
"@timestamp":"'$timestamp':'$usec'-0500"
}' > /home/jon/$second.cpm

curl --silent -XPOST "http://$elasticsearch_ip:9200/$index_name/Rad_Event/$pull_time$RANDOM" --data-binary @/home/jon/$second.cpm > /dev/null

let tsec=tsec+1
let second=second+1
done


# Cleanup
rm /home/jon/*.cpm
rm /home/jon/MOUNT/geiger/$file
#echo "Done $file"
done






