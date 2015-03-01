#! /bin/bash
/usr/share/elasticsearch/bin/elasticsearch -Des.config=/etc/elasticsearch/elasticsearch.yml
/usr/sbin/nginx -c /etc/nginx/nginx.conf
