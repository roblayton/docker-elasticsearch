docker-elasticsearch
====================

```
# make a mountable directory on the host
boot2docker ssh
sudo mkdir -p /data/log /data/data
sudo chgrp staff -R /data
sudo chmod 775 -R /data
exit

# build the image
docker build -t elasticsearch .

docker run -d -p 9200:9200 -p 9300:9300 --name elasticsearch -v /data:/data -t elasticsearch

# make sure elasticsearch is working
curl http://<BOOT2DOCKERIP>:9200/_search?pretty
```
