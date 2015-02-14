FROM java:8-jre
MAINTAINER Rob Layton hire@roblayton.com

# Update APT
RUN apt-get update

# Install build dependencies
RUN apt-get install -y wget

# Fetch oracle java ppa and elasticsearch public signing key
RUN \
  #add-apt-repository -y ppa:webupd8team/java && \
  wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
  echo 'deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main' | tee /etc/apt/sources.list.d/elasticsearch.list

# Install elasticsearch, nginx, supervisor
RUN \
  apt-get update && \
  apt-get -y install elasticsearch=1.4.2 nginx supervisor

# Nginx and elasticsearch reverse proxy
ADD nginx/sites-available/elasticsearch /etc/nginx/sites-available/
RUN \
  cd /etc/nginx/sites-enabled &&\
  rm default &&\
  ln -s ../sites-available/elasticsearch

# Run nginx in foreground and set number of worker processes to auto-detect
RUN echo "daemon off;\n" >> /etc/nginx/nginx.conf &&\
  sed -i '/^worker_processes/s,[0-9]\+,'"auto"',' /etc/nginx/nginx.conf

# Mount supervisor and elasticsearch config files
ADD supervisor/nginx.conf /etc/supervisor/conf.d/
ADD supervisor/elasticsearch.conf /etc/supervisor/conf.d/
ADD config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

# Clean up APT and temporary files when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define default command.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 80 9200 9300
