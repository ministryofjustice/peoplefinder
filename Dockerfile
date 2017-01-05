FROM ruby:2.3.3

# https://github.com/ministryofjustice/docker-templates/issues/37
# UTF 8 issue during bundle install
ENV LC_ALL C.UTF-8
ENV APPUSER moj
ENV UNICORN_PORT 3000

EXPOSE $UNICORN_PORT

# Add Githubs public keys into known_hosts
# Add application user
# add official nodejs repo
# install runit and nodejs
# Throw errors if Gemfile has been modified since Gemfile.lock
# Don't use any gems installed into the system. This makes the gem tree standalone
# Don't install documentation with gems
RUN apt-get update && apt-get install -y \
                              apt-transport-https && \
    mkdir $HOME/.ssh && \
    touch /root/.ssh/known_hosts && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    adduser $APPUSER --home /usr/src/app --shell /bin/bash --disabled-password --gecos "" && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node jessie main' > /etc/apt/sources.list.d/nodesource.list && \
    apt-get install -y \
            runit \
            nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log && \
    mkdir -p /usr/src/app && \
    mkdir -p /usr/src/app/public/assets && \
    bundle config --global frozen 1 && \
    bundle config --global disable_shared_gems 1 && \
    bundle config --global without test:development && \
    echo ':verbose: true' > $HOME/.gemrc && \
    echo 'install: --no-document' >> $HOME/.gemrc && \
    echo 'update: --no-document' >> $HOME/.gemrc

# Override imagemagick policy with recommended
# mitagation policy for imagetragick bug
# CVE-2016–3714 https://imagetragick.com/ 
COPY policy.xml /etc/ImageMagick-6/policy.xml

# Pre-install gems with native code to reduce build times
# Note these versions need to be in sync with gem versions in Gemfile.lock
RUN gem install --conservative kgio -v 2.9.3 && \
    gem install --conservative pg -v 0.18.1 && \
    gem install --conservative raindrops -v 0.13.0 && \
    gem install --conservative unf_ext -v 0.0.6 && \
    gem install --conservative nokogiri -v 1.6.7.2 && \
    gem install --conservative unicorn -v 4.8.3

WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN bundle install

COPY . /usr/src/app

RUN bundle exec rake assets:precompile RAILS_ENV=assets SUPPORT_EMAIL=''

ENTRYPOINT ["./run.sh"]
