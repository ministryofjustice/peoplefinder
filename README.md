<div align="center">

<a id="readme-top"></a>

<br>

<img alt="MoJ logo" src="https://moj-logos.s3.eu-west-2.amazonaws.com/moj-uk-logo.png" width="200">

# MoJ People Finder

[![repo standards badge](https://img.shields.io/endpoint?labelColor=231f20&color=005ea5&style=for-the-badge&label=MoJ%20Compliant&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fendpoint%2Fpeoplefinder&logo=data:image/png;base64,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)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#peoplefinder)

</div>

## Development

### Working on the Code

Work should be based off of, and PRed to, the main branch. We use the GitHub
PR approval process so once your PR is ready you'll need to have one person
approve it, and the CI tests passing, before it can be merged.


### Basic Setup

#### Cloning This Repository

Clone this repository then `cd` into the new directory

```
$ git clone git@github.com:ministryofjustice/peoplefinder.git
$ cd peoplefinder
```

### Installing the app for development

#### Latest Version of Ruby

If you don't have `rbenv` already installed, install it as follows:
```
$ brew install rbenv ruby-build
$ rbenv init
```

Follow the instructions printed out from the `rbenv init` command and update your `~/.bash_profile` or equivalent file accordingly, then start a new terminal and navigate to the repo directory.

Use `rbenv` to install the latest version of ruby as defined in `.ruby-version` (make sure you are in the repo path):

```
$ rbenv install
```

#### Dependencies

Postgresql

```
$ brew install postgresql
```

#### Setup

Use the following commands to install gems and javascript packages then create the database

```
$ bin/setup
```

#### Running locally:

To just run the web server without any background jobs (usually sufficient):

```
$ bin/rails server
```

The site will be accessible at http://localhost:3000.

## Configuration

These should be defined in the config/application.rb or in the enviroments/__environment__.rb files if the settings need to be
defined on a per environment basis.

`config.app_title` e.g. 'My New People Finder'

`config.default_url_options` e.g. { host: mail.peoplefinder.example.com }

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

## Token-based authentication

The token authentication method relies upon the users access to their email
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

1. you can view the server logs and copy the token from there, then paste it into the URL. See the image below:
![image](https://user-images.githubusercontent.com/22935203/114713734-4e6e3f00-9d29-11eb-86f2-a7a18a4f9eb7.png)

Then use the token on this URL: http://localhost:3000/tokens/3da4f4e2-8001-4437-b3ab-7e2b3f6e768c <-- replace with your token.3


## E-mails

People Finder sends a few types of e-mail using GOV.UK Notify

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

## Reminders

If the Peoplefinder is to be successful, profiles need to be populated and maintained.

## Exceptions

Any exceptions raised in any deployed environment will be sent to [Sentry](https://ministryofjustice.sentry.io/projects/peoplefinder).
