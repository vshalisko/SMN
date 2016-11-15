# SMN
### Scripts to deal with SMN data (Mexican Meteorological Service)
### *Programas para procesar datos de SMN*

1. `SMN_downloader.pl` - downloader for the full set of SMN raw data (> 2 Gb of text files)  
2. `SMN_normal_parser.pl` - parser of "climatic normals" files to store key data in single CSV table  

#### How-to run scripts in Docker
Run Ubuntu (latest)  
`docker pull ubuntu`  
`docker images`  
`docker run -it ubuntu bash`  
`exit`  
`docker ps -l`  
`docker exec -v /c/Users/vshal/Documents:/data -it 087d63d5be56 bash`  
`apt-get install cpanminus`
`apt-get install liblwp-protocol-https-perl`  
`apt-get install libcgi-pm-perl`  
`apt-get install libwww-mechanize-perl`  
`cpanm URI::Heuristic`  
`cd /data`  
`mkdir out`  
`perl SMN_downloater.pl url_input.txt`  
`exit`  
To create an image with changes in perl configuration:
`docker ps -l`  
`docker commit f4e7a15eec88 ubuntu:baseperl`  
`docker images`  

