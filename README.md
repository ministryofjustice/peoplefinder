# MoJ People Finder

[![CircleCI](https://circleci.com/gh/ministryofjustice/peoplefinder/tree/main.svg?style=svg)](https://circleci.com/gh/ministryofjustice/peoplefinder/tree/main)
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

PeopleFinder uses Ruby 3.2.2 and bundler 2.4.19

Install Ruby 3.2.2 using rbenv or rvm then install bundler using

`gem install bundler:2.4.19`

[Install Homebrew](http://brew.sh/) if it is not on your machine.

Install opensearch through brew (opensearch is an open source version of elasticsearch)

```
brew install opensearch
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
bundle exec rake # runs tests - make sure Opensearch is running
bundle exec rails s -b 0.0.0.0
```

In a separate terminal, run job worker for sending emails:

```cmd
cd peoplefinder
bundle exec rake jobs:work
```

## Configuration

These should be defined in the config/application.rb or in the enviroments/__environment__.rb files if the settings need to be
defined on a per environment basis.

`config.app_title` e.g. 'My New People Finder'

`config.default_url_options` e.g. { host: mail.peoplefinder.example.com }

`config.disable_token_auth` Disable the 'token-based authentication' feature

`config.open_search_url` Required for production (see Search section below)

`config.support_email` e.g. 'peoplefinder-support@example.com'

`config.send_reminder_emails` Set to true if reminder emails are to be sent by cronjobs

## Permitted domains

The system allows logging in for emails which have domains from the whitelist. The whitelist is in the database, managed by `PermittedDomain` model. At least one domain has to be whitelisted before anyone can log in (that applies to development too).

Adding a new domain to the production database from bash/zsh etc:
1. Log into the pod `kubectl get pods -n <NAMESPACE>`
2. Access the live pod shell `kubectl exec -it <POD> -n <NAMESPACE> ash`
3. Access rails console from within the shell - `rails c`
4. Use the following command to create the new domain.
   - Example: `PermittedDomain.create(domain: '<DOMAIN_NAME>')`
5. To test the domain has worked, visit the live app url. Attempt to sign in with the new domain:
   - Example: `email@<DOMAIN_NAME>`
6. If successful, you should be navigated to a page which states 'Link sent - check your email'

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

For local testing - There are a few ways you can get the token
1. Search your token from local development database
```
 select * from tokens where user_email = <the email you use for asking token from app> order by id desc;
```
http://localhost:3000/tokens/<token>

2. you can view the server logs and copy the token from there, then paste it into the URL. See the image below:
![image](https://user-images.githubusercontent.com/22935203/114713734-4e6e3f00-9d29-11eb-86f2-a7a18a4f9eb7.png)

Then use the token on this URL: http://localhost:3000/tokens/3da4f4e2-8001-4437-b3ab-7e2b3f6e768c <-- replace with your token.3


## E-mails

People Finder sends a few types of e-mail. E-mails are delivered using `delayed_job` adapter for `activejob`.

Run `bundle exec rake jobs:work` to activate the worker.

In production, periodic emails are sent to users that have:
- never logged in before;
- not updated their profile for a period of time; and
- not added a team description when they are a team leader.

## Search

To run the engine in production mode, `config.open_search_url` must be set in, for example, config/application.rb. The environment variable used to set it is `MOJ_PF_ES_URL`
See 'Configurable elements' above.

Use `localhost:9200` when calling OpenSearch search locally.

The following commands on kubernetes environments will call the open search proxy pod, which will then call open search on AWS to read or update data.

To check the health of the opensearch stack you can use the following, from either host instance. `wget` will download the information onto the pods so you can read the files using `cat`. Locally you can just use `curl`.

```
wget 'aws-es-proxy-service:9200/_cat/health?v'
```

or view ES settings and stats:

```
wget 'aws-es-proxy-service:9200/_cluster/stats/?pretty'
wget 'aws-es-proxy-service:9200/_cat/indices?v'
wget 'aws-es-proxy-service:9200/_cat/nodes?v'
```

If you get an IndexMissingException, you will need to index the Person model:

```
bundle exec rake environment opensearch:import:model CLASS='Person' FORCE=y
```

Or, alternatively:

```
rake peoplefinder:es:index_people
```

Or you can create the index from the console if the above rake commands fail:

```ruby
OpenSearch::Model.client = OpenSearch::Client.new(url: Rails.configuration.open_search_url).index(index: Person.index_name, body: {})
Person.__opensearch__.create_index! index: Person.index_name, force: true
```

And populate it:

`Person.import`

You can also delete the index:

`Person.delete_indexes`

To run specs without OpenSearch:

`bundle exec rspec . --tag ~opensearch`

If your shell is Zsh, you have to escape `~` by using `\~`.

**Note:** Unfortunately, at the moment there is no way to avoid having ES running locally, but you can use a docker container as mentioned above.

## Images

> ### Manipulation
>
> We use [MiniMagick](https://github.com/minimagick/minimagick) so either Imagemagick or Graphicsmagick need to be installed for image manipulation and for some of the tests.

> If using brew you can use the following command:

> `brew install imagemagick`

> ### Storage

> For the local dev environment the profile images are stored as files. For the deployed environments profile images are stored in their own AWS S3 bucket. The buckets do not grant any group permissions to non-AWS users (i.e. are private). Access to the images is achieved via presigned, time-limited urls generated by the app.

> Images that are uploaded to the bucket by the app explicitly prevent read to the "Everyone" AWS group using CarrierWave configuration in its initializer - the default for this config is true/public.

> ```
> config.fog_public = false # default: true
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

## Reminders

If the Peoplefinder is to be successful, profiles need to be populated and maintained.

###Support

A support email address is set as SUPPORT_EMAIL.

## Keeping secrets and sensitive information secure

There should be *absolutely no secure credentials* committed in this repo. Information about secret management can be found in the related confluence pages.

### prometheus_exporter
if you want to check/debug prometheus_exporter under local development environment, just open a separated terminial and get into this project root foler
and run the following command from command line
```
>prometheus_exporter
```
and also comment out the line for checking Rails.env from puma.rb and prometheus_exporter.rb temporarily
