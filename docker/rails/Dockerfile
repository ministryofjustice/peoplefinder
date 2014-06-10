# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to !
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
#FROM phusion/passenger-full:<VERSION>
# Or, instead of the 'full' variant, use one of these:
#FROM phusion/passenger-ruby19:<VERSION>
#FROM phusion/passenger-ruby21:<VERSION>
#FROM phusion/passenger-nodejs:<VERSION>
#FROM phusion/passenger-customizable:<VERSION>
FROM phusion/baseimage:latest

# Set correct environment variables.
ENV HOME /root
ENV APP_HOME /rails

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C3173AA6
RUN echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" > /etc/apt/sources.list.d/brightbox.list

RUN DEBIAN_FRONTEND='noninteractive' apt-get update
RUN DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends ruby2.0 ruby2.0-dev nodejs
RUN update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.0 171
RUN update-alternatives \
 --install /usr/bin/ruby ruby /usr/bin/ruby2.0 41 \
 --slave /usr/bin/erb erb /usr/bin/erb2.0 \
 --slave /usr/bin/testrb testrb /usr/bin/testrb2.0 \
 --slave /usr/bin/rake rake /usr/bin/rake2.0 \
 --slave /usr/bin/irb irb /usr/bin/irb2.0 \
 --slave /usr/bin/rdoc rdoc /usr/bin/rdoc2.0 \
 --slave /usr/bin/ri ri /usr/bin/ri2.0 \
 --slave /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby2.0.1.gz \
 --slave /usr/share/man/man1/erb.1.gz erb.1.gz /usr/share/man/man1/erb2.0.1.gz \
 --slave /usr/share/man/man1/irb.1.gz irb.1.gz /usr/share/man/man1/irb2.0.1.gz \
 --slave /usr/share/man/man1/rake.1.gz rake.1.gz /usr/share/man/man1/rake2.0.1.gz \
 --slave /usr/share/man/man1/ri.1.gz ri.1.gz /usr/share/man/man1/ri2.0.1.gz
RUN gem2.0 install rake bundler --no-rdoc --no-ri

# Preqs for bundler
RUN DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends git curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libpq-dev

ADD ./ /rails
# set WORKDIR
WORKDIR /rails

# bundle install
RUN /bin/bash -l -c "bundle install"

# Publish port 80
EXPOSE 80

# ...put your own build instructions here...
# install service files for runit
ADD docker/rails/unicorn.service /etc/service/unicorn/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
