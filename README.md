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
