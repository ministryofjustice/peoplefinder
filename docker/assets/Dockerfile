# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM moj-nginx:latest

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# install custom config files
ADD docker/assets/nginx.conf /etc/nginx/nginx.conf
ADD public /srv/http

ADD docker/assets/logstash-conf.sh /etc/logstash-conf.sh

# install service files for runit
ADD docker/assets/nginx.service /etc/service/nginx/run

# The way this base image handles envvars is pretty strange
COPY docker/app_env_vars /etc/container_environment/

EXPOSE 80 
