# Senior Civil Service Appraisals

## Environment

For email to work, certain environment variables must be set:

* SMTP_PASSWORD
* SMTP_USERNAME
* SMTP_PORT
* SMTP_ADDRESS
* SMTP_DOMAIN
* EMAIL_NOREPLY_ADDRESS

For local development, you can use a `.env` file; see `.env.sample` for an
example.

## Initial setup

First, create an admin user:

```sh
./bin/create_admin
```

The username and password will be echoed to the terminal:

```
Login created:
username: admin
password: l{VO/2=i;6|+
```

## Setting up users

### Via command line

```sh
./bin/import_users demo.csv
```

### Via web

Visit `/admin` and authenticate.
You can import users en masse via a CSV file or create/edit/delete them via
the web interface.

The CSV file should have no header row and three columns: *name*,
*email address*, and *manager's email address* (if appropriate).
A sample is included as `demo.csv`.

## Opening and closing the review period

The default is *open*.

### Via command line

```sh
rails runner 'Setting[:review_period] = "open"'
rails runner 'Setting[:review_period] = "closed"'
```

### Via web

Visit `/admin` and authenticate.
Use the *Close review period* or *Open review period* button.

## Sending introductions

The review period must be open.

### Via command line

```ruby
ReviewPeriod.instance.send_introductions
```

This will send introduction emails containing login links to all the users
created in the previous step.

In development, you can see the emails in the logs. Follow the `/go/` link to
be logged in as that user.

You can also generate a login link later on by:

```ruby
path = "/go/#{user.tokens.first.value}"
```

## Closing the review period

At the end of the feedback process, you can close the review period as
explained above.
You can then notify the participants that their feedback is ready to be viewed.

### Via command-line

```ruby
ReviewPeriod.instance.send_closure_notifications
```

## Utilities

* Continuous integration by [Travis](https://travis-ci.org/ministryofjustice/scs_appraisals).
* Code quality by [Code Climate](https://codeclimate.com/github/ministryofjustice/scs_appraisals).
