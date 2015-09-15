# GMC-Geiger-to-ElasticSearch
A script that will take the output of a GMC geiger counter (320 Plus for me) and import it in to an elasticsearch cluster.

My set up is as follows: 
* Working ElasticSearch cluster
* GMC PRO software (Windows) storing data per minute and resetting counts
* Windows folder accessible from Linux (cifs) or using something like Cygwin on Windows that can read the log files
* Access to delete log files once they are uploaded


The process is that the GMC PRO software stores a log file per minute of geiger count data. In that log file, there is a breakdown of a per second count. This script will read those files, create timestamps for each second entry, send to Elasticsearch, and then delete the file. All just runs on a cronjob. 
