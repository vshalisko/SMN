# SMN
### Scripts to deal with Mexican SMN data (National Meteorological Service)
### *Programas para procesar datos de SMN*

1. `SMN_downloader.pl` - downloader for the full set of SMN raw data (> 2 Gb of text files)  
2. `SMN_normals_parser.pl` - parser of "climatic normals" files to store key data in single tab-separated table  

#### How-to run scripts in Docker
Download and run Ubuntu image (latest)  
`docker pull ubuntu`  
`docker images`  
`docker run -v /c/Users/vshal/Documents:/data -it ubuntu bash`  
`exit`  
Enter the running Ubuntu container again  
`docker ps -l`  
`docker exec -it f4e7a15eec88 bash`  
Install some important stuff like `mc` and required perl modules (perl itself is already available as a part of Ubuntu)  
`apt-get update`  
`apt-get install curl`  
`apt-get install mc`  
`apt-get install cpanminus`  
`apt-get install liblwp-protocol-https-perl`  
`apt-get install libcgi-pm-perl`  
`apt-get install libwww-mechanize-perl`  
`cpanm URI::Heuristic`  
Change directory to /data shared with host machine, where the SMN_downloader.pl script is located  
`cd /data`  
`mkdir out_smn`  
Run scripts (check script user defined variables before)  
`perl SMN_downloater.pl url_input.txt`  
`perl SMN_normals_parser.pl`  
To create an image with this changes in perl configuration commit the image with changes  
`exit`  
`docker ps -l`  
`docker stop f4e7a15eec88`  
`docker commit f4e7a15eec88 ubuntu:baseperl`  
`docker images`  

