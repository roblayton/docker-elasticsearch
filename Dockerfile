FROM java:8-jre
MAINTAINER Rob Layton hire@roblayton.com

# Update APT
RUN apt-get update

# Install build dependencies
RUN apt-get install -y wget

# Fetch elasticsearch public signing key
RUN \
  wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
  echo 'deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main' | tee /etc/apt/sources.list.d/elasticsearch.list

# Install elasticsearch, nginx
RUN \
  apt-get update && \
  apt-get -y install elasticsearch=1.4.2 nginx

# Nginx and elasticsearch reverse proxy
ADD nginx/sites-available/elasticsearch /etc/nginx/sites-available/
RUN \
  cd /etc/nginx/sites-enabled &&\
  rm default &&\
  ln -s ../sites-available/elasticsearch

# Run nginx in foreground and set number of worker processes to auto-detect
RUN echo "daemon off;\n" >> /etc/nginx/nginx.conf &&\
  sed -i '/^worker_processes/s,[0-9]\+,'"auto"',' /etc/nginx/nginx.conf

# Mount elasticsearch config files
ADD config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

ADD run.sh /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

# Clean up APT and temporary files when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define default command.
CMD ["/usr/local/bin/run"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 80 9200 9300
