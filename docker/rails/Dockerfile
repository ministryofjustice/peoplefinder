FROM moj-ruby:latest

# Set correct environment variables.
ENV HOME /root
ENV APP_HOME /rails

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

ADD ./ /rails
# set WORKDIR
WORKDIR /rails

# Publish port 80
EXPOSE 80

ADD docker/rails/logstash-conf.sh /etc/logstash-conf.sh

# ...put your own build instructions here...
# install service files for runit
ADD docker/rails/unicorn.service /etc/service/unicorn/run

# The way this base image handles envvars is pretty strange
COPY docker/app_env_vars /etc/container_environment/

