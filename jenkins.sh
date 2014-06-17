
VERSION=$1

export PQ_REST_API_URL=https://api.wqatest.parliament.uk
#before_script:
#  - psql -c 'create role pq login createdb;' -U postgres


add_packages() {
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C3173AA6
  echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu precise main" > /etc/apt/sources.list.d/brightbox.list

  DEBIAN_FRONTEND='noninteractive' apt-get update
  DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends ruby2.0 ruby2.0-dev nodejs
  update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.0 171
  update-alternatives \
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
  gem2.0 install rake bundler --no-rdoc --no-ri


apt-get update
apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libpq-dev
}

#add_packages
bundle install
# Run Tesks
bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake spec


