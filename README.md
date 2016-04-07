# MoJ People Finder

![Build Status](https://circleci.com/gh/ministryofjustice/peoplefinder.png?circle-token=7af6dba1153f14c5e9b4ca7aec831720aeb00b1c)
[![Code
Climate](https://codeclimate.com/github/ministryofjustice/peoplefinder/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/peoplefinder)
[![Test
Coverage](https://codeclimate.com/github/ministryofjustice/peoplefinder/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/peoplefinder/coverage)

## Installing for development

This is not how people finder is actually deployed but provides an environment to do development on the app.

### Ubuntu install

On a Ubuntu 12.04 LTE box:

- install curl, git, postgresql, postgresql-dev-all, nodejs
- install rails through rvm. One way is:
  - `gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3`
  - `\curl -L https://get.rvm.io | bash -s stable --ruby`
- start a new shell
- `rvm gemset use global`
- `gem install bundler`
- `gem install rails`
- `clone this repository`
- `cd peoplefinder`
- `bundle install`
- `sudo su postgres createuser ubuntu` (or the name of the user the application will be running as)
- `createdb peoplefinder_development` (as the user the application will be running as)
- `bin/rake db:migrate RAILS_ENV=development`
- `bundle exec rails s -b 0.0.0.0`

Point your browser to http://0.0.0.0:3000 and you should see the application's start page.

### Mac OSX install

[Install Java](https://www.java.com/en/download/mac_download.jsp) if it is not on your machine.

[Install Homebrew](http://brew.sh/) if it is not on your machine.

On Mac OSX:

    brew install postgresql
    brew install imagemagick
    brew install phantomjs

    brew install homebrew/versions/elasticsearch17
    ln -sfv /usr/local/opt/elasticsearch17/*.plist ~/Library/LaunchAgents
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch17.plist

    git clone git@github.com:ministryofjustice/peoplefinder.git
    cd peoplefinder

    gem install eventmachine -v 1.0.5 -- --with-cppflags=-I/usr/local/opt/openssl/include

    bundle
    bundle exec rake db:setup
    bundle exec rake # runs tests
    bundle exec rails s -b 0.0.0.0

## Configuration

These should be defined in the config/application.rb or in the enviroments/__environment__.rb files if the settings need to be
defined on a per environment basis.

`config.app_title` e.g. 'My New People Finder'

`config.default_url_options` e.g. { host: mail.peoplefinder.example.com }

`config.disable_token_auth` Disable the 'token-based authentication' feature

`config.disable_communities` Disable the 'communities' feature

`config.elastic_search_url` Required for production (see Search section below)

`config.ga_tracking_id` Google Analytics tracking id [optional]. e.g. 'XXXX-XXX'

`config.support_email` e.g. 'peoplefinder-support@example.com'

`config.send_reminder_emails` Set to true if reminder emails are to be sent by cronjobs

## Permitted domains

The system allows logging in for emails which have domains from the whitelist. The whitelist is in the database, managed by `PermittedDomain` model. At least one domain has to be whitelisted before anyone can log in (that applies to development too).

In rails console:

```ruby
PermittedDomain.create(domain: 'some.domain.gov.uk')
```

## Authentication

Authentication requires two environment variables. You can obtain these by
visiting the [Google Developers Console](https://console.developers.google.com/).

Create a project, and wait for the process to complete.

Select **APIs & auth** from the sidebar, followed by **Credentials**, then
**Add credentials**, then select **OAuth 2.0 client ID** and **Web
application**.

Set **Authorized JavaScript origins** to the root (e.g. `http://localhost:3000`)
and **Authorized redirect URIs** to the OAuth redirect path, which will be
something like `http://localhost:3000/auth/gplus/callback`.

Set `GPLUS_CLIENT_ID` to the value of **Client ID** and `GPLUS_CLIENT_SECRET`
to **Client secret**.

You will also need to configure **OAuth consent screen** using the tab at the
top of the page: entering the name and setting all the URLs to the root of your
application is sufficient for logging in to work.

For local development, you can use a `.env` file; see `.env.sample` for an
example.

The permitted domains are configured in `config/application.rb`.

## Token-based authentication

An alternative 'token-based' authentication method is also supported. The
token authentication method relies upon the users access to their email
account to authenticate them.

Each time the user wishes to start a session, they need to generate an
authentication token. This can be done by entering their email address on the
login screen. They will be sent an email message containing a link with a
unique random token. Clicking on the link will allow them to login.

## E-mails

People finder sends a few types of e-mail. E-mails are delivered using `delayed_job` adapter for `activejob`. Run `rake jobs:work` to activate the worker.

### In Development

E-mails in development environment are setup to be delivered using `mailcatcher` gem. For that `mailcatcher` has to be started and then accessed on `http://localhost:1080` to read the delivered e-mails.

## Search

To run the engine in production mode, `config.elastic_search_url` must be set in, for example, config/application.rb.
See 'Configurable elements' above.

Heroku provides [Bonsai Elasticsearch](https://devcenter.heroku.com/articles/bonsai)
as an add-on.

You can install a development version from [Elasticsearch 1.7.3 downloads](https://www.elastic.co/downloads/past-releases/elasticsearch-1-7-3)
or with a package manager.
e.g. `brew install elasticsearch17`.

Elasticsearch requires [jdk version 7 or greater](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html).

If you get an IndexMissingException, you will need to index the Person model:

```
bundle exec rake environment elasticsearch:import:model CLASS='Person' FORCE=y
```

Or you can create the index from the console:

```
Person.__elasticsearch__.create_index! index: Person.index_name, force: true`
```

And populate it:

`Person.import`

You can also delete the index:

`Person.delete_indexes`

To run specs without Elasticsearch:

`bundle exec rspec . --tag ~elastic`

## Images

We use [MiniMagick](https://github.com/minimagick/minimagick) so either Imagemagick or Graphicsmagick need to be installed for image manipulation and for some of the tests.

If using brew you can use the following command:

`brew install imagemagick`

## Testing

You'll need to install PhantomJS in order to run the headless browser tests and the smoke_test.

On OSX:

`brew install phantomjs`

On a Linux box, you won't find a [pre-packaged headless phantomjs](http://phantomjs.org/download.html) as of this writing. You might need to recompile it from source (we have it in a private apt repository).

Also, if you'd like test coverage for Javascript you'll need to have Node and Istanbul installed. The easiest way to do this is installing Node via nvm and then use npm to install Istanbul like so:

`npm install -g istanbul`

## View templates

The application layout is set by the [moj_internal_template](https://github.com/ministryofjustice/moj_internal_template) that is installed as part of this engine.

You can override this layout in wrapper application, create your own file:

`app/views/layouts/peoplefinder/peoplefinder.html.haml`

## Translation file

A lot of the text in the views is configurable in the translations file.

You can override these in wrapper application by creating your own file:

`config/locales/en.yml`

## Utilities

### Random data generator for testing

The `RandomGenerator` is able to generate several layers of teams and people with randomly generated details in those teams.

Usage:

```Ruby

  group = Group.find(...)

  # initialise the generator with a parent group
  generator = RandomGenerator.new(group)

  # clean all subgroups and people within the provided parent group
  generator.clear

  # generate team structure and people with the given parameters
  groups_levels = 2 # number of levels to generate
  groups_per_level = 3 # how many teams per each level
  people_per_group = 5 # how many people should be in the bottom most teams
  domain = 'fake.gov.uk' # which e-mail address should be used for e-mails (has to be whitelisted)
  generator.generate(groups_levels, groups_per_level, people_per_group, domain)
```

### Development tools

CI by [Travis](https://travis-ci.org/ministryofjustice/peoplefinder).

Software metrics by [Code Climate](https://codeclimate.com/github/ministryofjustice/peoplefinder)

## Reminders

If the Peoplefinder is to be successful, profiles need to be populated and maintained.

###Support

A support email address is set as SUPPORT_EMAIL.
