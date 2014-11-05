# MoJ People Finder

This is a rails engine that can be mounted inside a rails 4 application.

A working example can be seen at https://github.com/alphagov/gds-peoplefinder

## Creating your own wrapper application

If you want to deploy peoplefinder yourself, you can create your own wrapper
application quite easiliy.

Start by creating a bare rails application:

```
$ rails application new my_peoplfinder
```

Then you need to modify the `Gemfile` to include the peoplefinder engine gem:

```
gem 'peoplefinder'
```

The peoplefinder engine requires some forked / tagged versions gems. It's not
possible to specify these forked requirements in the `peoplefinder` gemspec,
so you need to specify them in the `Gemfile` of the wrapper application:

```
gem 'carrierwave',
  git: 'https://github.com/carrierwaveuploader/carrierwave.git',
  tag: 'cc39842e44edcb6187b2d379a606ec48a6b5e4a8'

gem 'omniauth-gplus',
  git: 'https://github.com/ministryofjustice/omniauth-gplus.git'
```

Install the gems with bundler:

```
bundle install
```

## Mounting the engine

In config/routes.rb:

`mount Peoplefinder::Engine, at: "/"`

## Importing migrations from engine

If the engine has new database migrations, you can import them into this application to apply them to the application database using the following:

`$ bundle exec rake peoplefinder:install:migrations`

This copies the migrations into the application's `db/migrate` directory. You should commit any such imported migration files to this applications repo:

`$ git add db/migrate $ git commit -m 'Imported new migrations from engine'`

You should then run the migrations in the usual way:

` $ bundle exec rake db:migrate`

And commit the `schema.rb`


## Configuration

These should be defined in the config/application.rb or in the enviroments/__environment__.rb files if the settings need to be
defined on a per environment basis.

`config.app_title` e.g. 'My New People Finder'

`config.default_url_options` e.g. { host: mail.peoplefinder.example.com }

`config.disable_profile_tags` Hide the tagging (Skills and expertise) functionality from the edit profile page

`config.disable_token_auth` Disable the 'token-based authentication' feature

`config.disable_communities` Disable the 'communities' feature

`config.elastic_search_url` Required for production (see Search section below)

`config.ga_tracking_id` Google Analytics tracking id [optional]. e.g. 'XXXX-XXX'

`config.support_email` e.g. 'peoplefinder-support@example.com'

`config.valid_login_domains` Restrict login to email addresses from domains that match the string or regular expresson. e.g. `[/(.*)\.gov\.uk\Z/, 'example.com']`

## Authentication

Authentication requires two environment variables. You can obtain these by
visiting the [Google Developers Console](https://console.developers.google.com/)
and selecting **APIs & auth** from the sidebar, followed by **Credentials**,
then **Create new Client ID**.

Set `GPLUS_CLIENT_ID` to the value of **Client ID** and `GPLUS_CLIENT_SECRET`
to **Client secret**.

You will also need to configure **Consent screen** below for logging in to work.

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

## Search

To run the engine in production mode, `config.elastic_search_url` must be set in, for example, config/application.rb.
See 'Configurable elements' above.


Heroku provides [Bonsai Elasticsearch](https://devcenter.heroku.com/articles/bonsai)
as an add-on.

You can install a development version from [Elasticsearch downloads](http://www.elasticsearch.org/download/)
or with a package manager.
e.g. `brew install elasticsearch`.

Elasticsearch requires [jdk version 7 or greater](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html).

If you get an IndexMissingException, you will need to index the Person model:

```
bundle exec rake environment elasticsearch:import:model CLASS='Peoplefinder::Person' FORCE=y
```

Or you can create the index from the console:

```
Peoplefinder::Person.__elasticsearch__.create_index! index: Peoplefinder::Person.index_name, force: true`
```

And populate it:

`Peoplefinder::Person.import`

You can also delete the index:

`Peoplefinder::Person.delete_indexes`

To run specs without Elasticsearch:

`bundle exec rspec . --tag ~elastic`

## Images

We use [MiniMagick](https://github.com/minimagick/minimagick) so either Imagemagick or Graphicsmagick need to be installed for image manipulation and for some of the tests.

If using brew you can use the following command:

`brew install imagemagick`

## Testing

You'll need to install PhantomJS in order to run the headless browser tests.

`brew install phantomjs`

Also, if you'd like test coverage for Javascript you'll need to have Node and Istanbul installed. The easiest way to do this is installing Node via nvm and then use npm to install Istanbul like so:

`npm install -g istanbul`

## View templates

The application layout is set by the [moj_internal_template](https://github.com/ministryofjustice/moj_internal_template) that is installed as part of this engine.

You can override this layout in wrapper application, create your own file:

`app/views/layouts/peoplefinder/peoplefinder.html.haml`


## Angular.js notes

The organisational browser uses angular.js. When heroku compiles the assets, the minified js is mangled and does not work.

Asset mangling is prevented in the engine with help of the uglifier gem.

Make sure that this is not overwritten in the wraper by commenting out the js_compressor in config/environments/production.rb:

`# config.assets.js_compressor = :uglifier`


## Translation file

A lot of the text in the views is configurable in the translations file.

You can override these in wrapper application by creating your own file:

`config/locales/en.yml`

## Utilities

CI by [Travis](https://travis-ci.org/ministryofjustice/peoplefinder).

Software metrics by [Code Climate](https://codeclimate.com/github/ministryofjustice/peoplefinder)

## Reminders

If the Peoplefinder is to be successful, profiles need to be populated and maintained.

### Inadequate profiles

To view a list of people whose profiles are deemed to be 'inadequate' (not having a phone number, location and photo):

`rake peoplefinder:inadequate_profiles`

To send emails prompting people to complete their profiles:

`rake peoplefinder:inadequate_profile_reminders`

##Environment Variables

###Support

A support email address is set as SUPPORT_EMAIL.
