
# MoJ People Finder

![Build Status](https://circleci.com/gh/ministryofjustice/peoplefinder.png?circle-token=7af6dba1153f14c5e9b4ca7aec831720aeb00b1c)
[![Code
Climate](https://codeclimate.com/github/ministryofjustice/peoplefinder/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/peoplefinder)
[![Test
Coverage](https://codeclimate.com/github/ministryofjustice/peoplefinder/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/peoplefinder/coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/ministryofjustice/peoplefinder.svg)](https://gemnasium.com/github.com/ministryofjustice/peoplefinder)


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

PeopleFinder uses Ruby 2.3.7 and bundler 1.14.6

Install Ruby 2.3.7 using rbenv or rvm then install bundler using

`gem install bundler:1.14.6`

PeopleFinder relies on Elasticsearch for its search functionality, and ElasticSearch requires Java to be installed on your Mac. Presently we use Elastisearch 1.7 which requires Java 8.

Oracle recently changed the licensing for Java such that you need to agree to their updated licence agreement before you download it. This in turn has meant that they have broken all previous methods for obtaining older versions of Java, so most of the suggestions that previously worked no longer do. At time of writing (late 2019) the best method is to install OpenJDK using homebrew as follows.

```cmd
$ brew tap homebrew/cask-versions
$ brew cask install homebrew/cask-versions/adoptopenjdk8
```

If you need to have other versions of Java installed, you may need to add this to your `~/.bash_profile` file or find some other way of switching the active version.

```
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
```

[Install Homebrew](http://brew.sh/) if it is not on your machine.

Regarding Elasticsearch, unfortunately the version we use is no longer available from Homebrew. There are two options presently:

Either:

Download and run the binary executable from the Elastic website and extract it into a sensible location where you don't mind keeping it - https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.0.zip then change into that  directory and run

`$ ./elasticsearch`

Or:

Run this docker image maintained by a third party:
```cmd
docker run --name elasticsearch \
>   --publish 9200:9200 \
>   [quay.io/trackmaven/elasticsearch:1.7](http://quay.io/trackmaven/elasticsearch:1.7)
```

Install remaining dependencies on Mac OSX:

```cmd
brew install postgresql
brew install imagemagick
brew cask install phantomjs

git clone git@github.com:ministryofjustice/peoplefinder.git
cd peoplefinder

gem install eventmachine -v 1.0.5 -- --with-cppflags=-I/usr/local/opt/openssl/include

# if you encounter issues with the bundler version
# for example if you have a later version installed in this ruby,
# add _1.14.6_ to the following commands e.g.:
# `bundle _1.14.6_`
bundle
bundle exec rake db:setup
bundle exec rake peoplefinder:db:reload # includes demo data
bundle exec rake # runs tests - make sure Elasticsearch is running
bundle exec rails s -b 0.0.0.0
```

In a separate terminal, run job worker for sending emails:

```cmd
cd peoplefinder
bundle exec rake jobs:work
```

To catch emails in development, in a separate terminal, run `mailcatcher` and view emails at `http://localhost:1080`:

```cmd
cd peoplefinder
mailcatcher
```

## Configuration

These should be defined in the config/application.rb or in the enviroments/__environment__.rb files if the settings need to be
defined on a per environment basis.

`config.app_title` e.g. 'My New People Finder'

`config.default_url_options` e.g. { host: mail.peoplefinder.example.com }

`config.disable_token_auth` Disable the 'token-based authentication' feature

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

Authentication for Log in to People Finder in the various environments (dev/staging/prod) is handled by the setting of `GPLUS_CLIENT_ID` and `GP_CLIENT_SECRET` environment variables in the [private People Finder Deployment repo](https://github.com/ministryofjustice/pf-deploy/)

You can configure your local machine for authentication by obtaining an OAuth Client ID and Secret from google+ and setting them in a `.env.local` file (.gitignore'd).

To create your own ID and SECRET:

  * visit the [Google Developers Console](https://console.developers.google.com/).
  * Create a project, optionally naming it `PeopleFinder-local`, and wait for the process to complete.

  * Select **Google+ API** from the central panel "Overview", then hit the Enable button. Wait for process to complete then follow link to **Go to Credentials** or choose **Credentials** from left sidebar, then follow the steps required to create an **OAuth 2.0 client ID** for a **Web application**.

  * On **OAuth consent page** you can optonally set the **Product name** to `PeopleFinder-local`
  * On the credentials page:
    * set Application type to Web application
    * set Name to `PeopleFinder-local`
    * set **Authorized JavaScript origins** to the root (e.g. `http://localhost:3000`)
    * set **Authorized redirect URIs** to the OAuth redirect path, currently `http://localhost:3000/auth/gplus/callback`, but check routes.rb

Hit create/continue until process is complete and you will receive a client ID and client SECRET.

For local development purposes the ID and SECRET can be stored in your bash profile or you can create an `.env.local` file based on `.env.example` and set them, as below.

```
GPLUS_CLIENT_ID=your_gplus_client_id
GPLUS_CLIENT_SECRET=your_gplus_client_secret
```

The permitted domains are configured in `config/application.rb`.

## Token-based authentication

An alternative 'token-based' authentication method is also supported. The
token authentication method relies upon the users access to their email
account to authenticate them.

Each time the user wishes to start a session, they need to generate an
authentication token. This can be done by entering their email address
(from a permitted domain) on the login screen. They will be sent an email
message containing a link with a unique random token. Clicking on the link
will allow them to login.


## E-mails

People Finder sends a few types of e-mail. E-mails are delivered using `delayed_job` adapter for `activejob`.

Run `bundle exec rake jobs:work` to activate the worker.

In production, periodic emails are sent to users that have:
- never logged in before;
- not updated their profile for a period of time; and
- not added a team description when they are a team leader.

Cronjobs are created to daily check for users matching these conditions and send emails. Cronjobs are created via the
`whenever` gem and configured here: https://github.com/ministryofjustice/peoplefinder/blob/master/config/schedule.rb

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

To check the health of the elasticsearch (ES) stack you can use the following, from either host instance:

```
curl 'localhost:9200/_cat/health?v'
```

or view ES settings and stats:

```
curl 'localhost:9200/_cluster/stats/?pretty'
curl 'localhost:9200/_cat/indices?v'
curl 'localhost:9200/_cat/nodes?v'
```

If you get an IndexMissingException, you will need to index the Person model:

```
bundle exec rake environment elasticsearch:import:model CLASS='Person' FORCE=y
```

Or, alternatively:

```
rake peoplefinder:es:index_people
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

> ### Manipulation
>
> We use [MiniMagick](https://github.com/minimagick/minimagick) so either Imagemagick or Graphicsmagick need to be installed for image manipulation and for some of the tests.

> If using brew you can use the following command:

> `brew install imagemagick`

> ### Storage

> For the dev environment the profile images are stored as files in the container and therefore do not persist between container deploys. For the Demo, Staging and Production environments profile images are stored in their own AWS S3 bucket. The buckets do not grant any group permissions to non-AWS users (i.e. are private). Access to the images is achieved via presigned, time-limited urls generated by the app.

> Images that are uploaded to the bucket by the app explicitly prevent read to the "Everyone" AWS group using CarrierWave configuration in its initializer - the default for this config is true/public.

> ```
> config.fog_public = false # default: true
> ```

> Profile images had originally applied the AWS Canned-ACL `public-read`, rendering them public, and therefore two rake tasks have been written to assist with amending the Access Control List for image objects.

> To make images private (and therefore accessible only via presigned-urls):

> ```
> rake peoplefinder:S3:privatise_images
> ```

> To make images available to the "Everyone" AWS group:

> ```
> rake peoplefinder:S3:publicise_images
> ```

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

You can also generate semi-random data using the rake task `peoplefinder:data:demo` which is called as part of `peoplefinder:db:reload`. Repeatedly running `peoplefinder:demo:data` will add members to the example groups it creates.

### Useful rake tasks

Run `rake -T | grep people` for latest list:

```
rake peoplefinder:data:demo                    # create basic demonstration data
rake peoplefinder:data:demo_csv[count,file]    # create a valid csv for load testing, [count: number of records=500], [file: path to file=spec/fixtures/]
rake peoplefinder:db:clear                     # drop all tables
rake peoplefinder:db:reload                    # drop tables, migrate, seed and populate with demonstration data for development purposes
rake peoplefinder:db:reset_column_information  # reset all column information
rake peoplefinder:import:csv_check[path]       # Check validity of CSV file before import
rake peoplefinder:import:csv_import[path]      # Import valid CSV file
```

### Mail previews

Mail previews can be found at `http://localhost:3000/rails/mailers`, assuming the server is running locally on port 3000.

### Geckoboard

A <a href="https://app.geckoboard.com/edit/dashboards/116571" target="_blank">Geckboard dashboard</a> is used for the visualization of various metrics from Peoplefinder. These metrics take the form of either pollable endpoints locate under `app/metrics/..` OR pushable/publishable geckboard datasets located under `lib/geckoboardpublisher/..`

The datasets are scheduled for pushing in `conf/schedule.rb` using the whenever gem and cron installed on the worker instances (production environment only).

Once published, datasets are wired up on Geckboard by adding a widget, specifying "Datasets" for the connection type and selecting the published dataset from the list available.

For testing purposes you can manually publish reports as below:

```
GeckboardPublisher::ProfilePercentagesReport.new.publish!
```

which will, on staging, create a dataset called `peoplefinder-staging.profile_percentages_report`

and to remove the report...

```
GeckboardPublisher::ProfilePercentagesReport.new.unpublish!
```

NOTE: there is a limit of 100 datasets per geckboard account and a limit of 5000 records per dataset. Further, you can only push a maximum of 500 records per request.

### Front end development

A large part of the audience for Peoplefinder are, at time of writing, still reliant on
Windows XP for their OS and IE7 for their browser. Consequently considerable styling and javascript needs IE7 workarounds. To assist, you can install Virtual Box VMs using the guide below

1. install virtual box - [Virtualbox](https://www.virtualbox.org/wiki/Downloads)

2. you can download fairly reliable MS Windows VMs using this site at [xdissent](http://xdissent.github.io/ievms/). The simplest method is to download the Windows 7 with IE10 VM and use the Developer tools in IE10 to change ***Browser mode*** and ***Document mode*** to IE7.
   ```
   curl -s https://raw.githubusercontent.com/xdissent/ievms/master/ievms.sh | env IEVMS_VERSIONS="10" bash
   ```
3. once command above has completed power on the machine in virtual box, start IE and use http://10.0.2.2:3000 (i.e. 10.0.2.2 maps to the host's `localhost` IP)

4. you can map the VMs localhost to 10.0.2.2 to allow GPlus OAuth login to function by amending the hosts file, `C:\Windows\System32\drivers\etc\hosts`, to add the line below:
```
10.0.2.2    localhost
```

#### Optional config for your VM for local development:

  * enable host to VM copy/paste

    ```
    vbox > machine > settings > General(tab) > Advanced(tab) > Shared clipboard(dropdown) > Bidirectionl
    ```

### Development tools

CI by [Travis](https://travis-ci.org/ministryofjustice/peoplefinder).

Software metrics by [Code Climate](https://codeclimate.com/github/ministryofjustice/peoplefinder)

## Reminders

If the Peoplefinder is to be successful, profiles need to be populated and maintained.

###Support

A support email address is set as SUPPORT_EMAIL.
