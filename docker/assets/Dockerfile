# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.9

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
# update the package sources
RUN apt-get update
# we use the enviroment variable to stop debconf from asking questions..
RUN DEBIAN_FRONTEND='noninteractive' apt-get install -y nginx

# install custom config files
ADD docker/assets/nginx.conf /etc/nginx/nginx.conf
ADD public /srv/http

# install service files for runit
ADD docker/assets/nginx.service /etc/service/nginx/run

EXPOSE 80 
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
