MoJ People Finder
=================

![Build Status](https://circleci.com/gh/ministryofjustice/peoplefinder.png?circle-token=7af6dba1153f14c5e9b4ca7aec831720aeb00b1c)

Configuration
-------------

These should be defined in the config/application.rb or in the enviroments/**environment**.rb files if the settings need to be defined on a per environment basis.

`config.app_title` e.g. 'My New People Finder'

`config.default_url_options` e.g. { host: mail.peoplefinder.example.com }

`config.disable_profile_tags` Hide the tagging (Skills and expertise) functionality from the edit profile page

`config.disable_token_auth` Disable the 'token-based authentication' feature

`config.disable_communities` Disable the 'communities' feature

`config.elastic_search_url` Required for production (see Search section below)

`config.ga_tracking_id` Google Analytics tracking id [optional]. e.g. 'XXXX-XXX'

`config.support_email` e.g. 'peoplefinder-support@example.com'

Authentication
--------------

Authentication requires two environment variables. You can obtain these by visiting the [Google Developers Console](https://console.developers.google.com/) and selecting **APIs & auth** from the sidebar, followed by **Credentials**, then **Create new Client ID**.

Set `GPLUS_CLIENT_ID` to the value of **Client ID** and `GPLUS_CLIENT_SECRET` to **Client secret**.

You will also need to configure **Consent screen** below for logging in to work.

For local development, you can use a `.env` file; see `.env.sample` for an example.

The permitted domains are configured in `config/application.rb`.

Token-based authentication
--------------------------

An alternative 'token-based' authentication method is also supported. The token authentication method relies upon the users access to their email account to authenticate them.

Each time the user wishes to start a session, they need to generate an authentication token. This can be done by entering their email address on the login screen. They will be sent an email message containing a link with a unique random token. Clicking on the link will allow them to login.

Search
------

To run the engine in production mode, `config.elastic_search_url` must be set in, for example, config/application.rb. See 'Configurable elements' above.

Heroku provides [Bonsai Elasticsearch](https://devcenter.heroku.com/articles/bonsai) as an add-on.

You can install a development version from [Elasticsearch downloads](http://www.elasticsearch.org/download/) or with a package manager. e.g. `brew install elasticsearch`.

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

Images
------

We use [MiniMagick](https://github.com/minimagick/minimagick) so either Imagemagick or Graphicsmagick need to be installed for image manipulation and for some of the tests.

If using brew you can use the following command:

`brew install imagemagick`

Testing
-------

You'll need to install PhantomJS in order to run the headless browser tests.

`brew install phantomjs`

Also, if you'd like test coverage for Javascript you'll need to have Node and Istanbul installed. The easiest way to do this is installing Node via nvm and then use npm to install Istanbul like so:

`npm install -g istanbul`

View templates
--------------

The application layout is set by the [moj_internal_template](https://github.com/ministryofjustice/moj_internal_template) that is installed as part of this engine.

You can override this layout in wrapper application, create your own file:

`app/views/layouts/peoplefinder/peoplefinder.html.haml`

Translation file
----------------

A lot of the text in the views is configurable in the translations file.

You can override these in wrapper application by creating your own file:

`config/locales/en.yml`

Utilities
---------

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

Reminders
---------

If the Peoplefinder is to be successful, profiles need to be populated and maintained.

### Inadequate profiles

To view a list of people whose profiles are deemed to be 'inadequate' (not having a phone number, location and photo):

`rake peoplefinder:inadequate_profiles`

To send emails prompting people to complete their profiles:

`rake peoplefinder:inadequate_profile_reminders`

##Environment Variables

###Support

A support email address is set as SUPPORT_EMAIL.
