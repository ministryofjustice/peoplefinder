FROM moj-peoplefinder:latest

# Set correct environment variables.
ENV HOME /root
ENV APP_HOME /rails

ENV MOJ_PF_DATABASE_URL postgres://pf:pf@172.17.42.1/pf
ENV MOJ_PF_ES_URL http://172.17.42.1:9200/

ADD ./ /rails
WORKDIR /rails

EXPOSE 80

ADD docker/rails/unicorn.service /etc/service/000_unicorn/run
ADD docker/rails/delayed_job.service /etc/service/001_delayed_job/run
ADD docker/rails/logstash-conf.sh /etc/logstash-conf.sh

COPY docker/app_env_vars /etc/container_environment/

