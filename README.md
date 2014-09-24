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

First, create users and their management relationships. This is achieved by
importing a CSV file. A short CSV containing the demo users is included as
`demo.csv`:

```sh
./bin/import_users demo.csv
```

Sending introduction emails is explained in the next section.

## Opening the review period

Set the review process to open via the `REVIEW_PERIOD` environment variable:

```sh
REVIEW_PERIOD=OPEN
```

Next, start the review process:

```ruby
ReviewPeriod.new.send_introductions
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

At the end of the feedback process, you can 'close' the review period
by setting an environment variable:

```sh
REVIEW_PERIOD=CLOSED
```

When the review period is 'closed', you can notify the participants that
their feedback is ready to be viewed:

```ruby
ReviewPeriod.new.send_closure_notifications
```

To check the list of participants:

```ruby
ReviewPeriod.new.participants
```

## Utilities

CI by [Travis](https://travis-ci.org/ministryofjustice/scs_appraisals).
