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

## Setting it up for development

Create users and their management relationships. This is achieved by
importing a CSV file using the `UsersImporter` or by creating `User` records:

```ruby
a = User.create(
  name: 'name', email: 'user@example.com', participant: true
)
b = User.create(
  name: 'name', email: 'user@example.com', participant: true, manager: a
)
```

Start the review process:

```ruby
ReviewPeriod.new.send_introductions
```

In development, you can see the emails in the logs. Follow the `/go/` link to
be logged in as that user.

You can also generate a login link later on by:

```ruby
path = "/go/#{user.tokens.first.value}"
```

## Opening the review period

Set the review process to open via the environment variable:

```sh
REVIEW_PERIOD=OPEN
```

You can send introduction emails to all users in the system:

```ruby
ReviewPeriod.new.send_introductions
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
