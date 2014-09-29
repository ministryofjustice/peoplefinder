# MoJ People Finder

[![Code Climate](https://codeclimate.com/github/ministryofjustice/peoplefinder/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/peoplefinder)

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

## Search

Heroku provides [Bonsai Elasticsearch](https://devcenter.heroku.com/articles/bonsai)
as an add-on.

You can install a development version from [Elasticsearch downloads](http://www.elasticsearch.org/download/)
or with a package manager.
e.g. `brew install elasticsearch`.

Elasticsearch requires [jdk version 7 or greater](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html).

If you get an IndexMissingException, you will need to index the Person model:

`bundle exec rake environment elasticsearch:import:model CLASS='Person' FORCE=y`

Or you can build the index from the console:

`Person.__elasticsearch__.create_index! index: Person.index_name, force: true`
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

You'll need to install PhantomJS in order to run the headless browser tests.

`brew install phantomjs`

Also, if you'd like test coverage for Javascript you'll need to have Node and Istanbul installed. The easiest way to do this is installing Node via nvm and then use npm to install Istanbul like so:

`npm install -g istanbul`

## Utilities

CI by [Travis](https://travis-ci.org/ministryofjustice/peoplefinder).

Software metrics by [Code Climate](https://codeclimate.com/github/ministryofjustice/peoplefinder)

## Releases

Within the bin directory there is a file called release.sh. The purpose of this script is for management of releases i.e tagged versions compatible with Githubs release conventions.

To create a new release:

`bin/release.sh create`

Listing all releases:

`bin/release.sh list`

Deleting a particular release:

`bin/release.sh remove RELEASE_VERSION`

Perform a git show of a release:

`bin/release.sh show RELEASE_VERSION`

List all releases with verbose output:

`bin/release.sh ll`

Last release:

`bin/release.sh last`

##Deployment

For this example we're making the following assumptions:

- You're using Heroku
- You've setup staging and production environments as git remotes that we'll henceforth refer to as staging and production

First if you don't already have a release, create a new one from the current branch:

`bin/release.sh create`

The name of the tagged released should be echoed back to the console. And will read back like release/ISO_DATE_TIME.
Copy and past it as an argument together with '^{}:master' appended to the configured git remote of your choosing. For this example we'll use staging.

`git push -f staging release/2014-08-08T08.59.09Z^{}:master`

You should then see the standard git based deployment process for Heroku kick into action.

It should be noted that depending on your circumstances e.g running migrations etc. You may want to run the following sequence of commands:

`heroku maintenance:on` maintenance mode on

`heroku ps:scale worker=0` scale down any background workers

`git push -f staging release/2014-08-08T08.59.09Z^{}:master` push the code to heroku

`heroku run rake db:migrate` run your migrations

`heroku ps:scale worker=1` turn your workers back on

`heroku maintenance:on` unleash the app to the world


##SSL

If you look in the .env.example you'll see a setting called SSL_ON which defaults to false. However the application is fully able to take advantage of
SSL and by setting SSL_ON to true it will force the application to use SSL only which you'll definitely want for production.

To do this on Heroku run:

`heroku config:set SSL_ON=true`


##Reminders

If the Peoplefinder is to be successful, profiles need to be populated and maintained.

###Inadequate profiles

To view a list of people whose profiles are deemed to be 'inadequate' (not having a phone number, location and photo):

`rake peoplefinder:inadequate_profiles`

To send emails prompting people to complete their profiles:

`rake peoplefinder:inadequate_profile_reminders`


##Environment Variables

###Support

A support email address is set as SUPPORT_EMAIL.
